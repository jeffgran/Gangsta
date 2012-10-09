require 'helper'


shared_examples 'bidirectional transformers in multiple formats' do
  # it 'should serialize to RDF/XML and back again' do
  #   before = post
  #   rdfxml = post.as_gangsta(format: :rdfxml)
  #   after = Post.gangstify(rdfxml, format: :rdfxml)
  #   before.should == after
  # end

  it 'should serialize to simple XML and back again' do
    before = post
pp "before:"
pp post
    xml = post.as_gangsta(format: :simple_xml)
pp "xml:"
puts xml
    after = Post.gangstify(xml, format: :simple_xml)
pp "after:"
pp after
    before.should == after
  end
end

describe Gangsta do
  context "simple dictionary" do

    before do
      class Post
        include Gangsta
        attr_accessor :title, :body, :author_email
        gangsta do
          title vocab: "http://purl.org/dc/terms/"
          body  vocab: "http://purl.org/dc/terms/"
          author_email vocab: "http://purl.org/dc/terms/"
        end
        
        def ==(another)
          title == another.title &&
            body == another.body &&
            author_email == another.author_email
        end
        
      end
    end

    let(:post) { Post.new.tap do |p|
        p.title = "This is the title"
        p.body = "This is the body"
        p.author_email = "author@example.com"
      end
    }

    it_behaves_like 'bidirectional transformers in multiple formats'
  end
  
  context 'nested dictionary' do
    before do
      class Post
        include Gangsta
        attr_accessor :title, :body, :author_email, :author_name, :comments

        gangsta do
          title vocab: "http://purl.org/dc/terms/"
          body vocab: "http://purl.org/dc/terms/"
          author_info type: :passthrough do
            author_name vocab: "http://purl.org/dc/terms/"
            author_email vocab: "http://purl.org/dc/terms/"
          end

          comments getter: :my_comments, type: :list, classname: 'Comment' do
            comment type: :passthrough do
              text
              author
            end
          end
        end
        
        def my_comments
          @comments ||= ['uno', 'dos', 'tres'].map do |txt|
            Comment.new.tap do |c|
              c.text = txt
              c.author = "anonymous #{txt}"
            end
          end
        end

        def comments_map
          {}.tap do |h|
            comments.map{|c| h[c.author] = c.text}
          end
        end

        def == (another)
          title == another.title &&
            body == another.body &&
            author_email == another.author_email &&
            author_name == another.author_name &&
            comments_map == another.comments_map
        end
      end

      class Comment
        attr_accessor :text, :author
      end
    end

    let(:post) { Post.new.tap do |p|
        p.title = "This is the title"
        p.body = "This is the body"
        p.author_email = "author@example.com"
        p.author_name = "Yer Mom"
      end
    }

    it_behaves_like 'bidirectional transformers in multiple formats'
  end

end
