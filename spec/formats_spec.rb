require 'helper'


shared_examples 'bidirectional transformers in multiple formats' do
  let(:post) { Post.new.tap do |p|
      p.title = "This is the title"
      p.body = "This is the body"
      p.author_email = "author@example.com"
    end
  }
  # it 'should serialize to RDF/XML and back again' do
  #   before = post
  #   rdfxml = post.as_gangsta(format: :rdfxml)
  #   after = Post.gangstify(rdfxml, format: :rdfxml)
  #   before.should == after
  # end

  it 'should serialize to simple XML and back again' do
    before = post
    xml = post.as_gangsta(format: :simple_xml)
    after = Post.gangstify(xml, format: :simple_xml)
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
          author_info do
            author_name vocab: "http://purl.org/dc/terms/"
            author_email vocab: "http://purl.org/dc/terms/"
          end
          comments list_of: 'Comment', getter: :comments do |c|
            comment do
              text
              author
            end
          end
        end
        
        def comments
          ['uno', 'dos', 'tres'].map do
            Comment.new
          end
        end

        class Comment
          attr_accessor :text, :author
        end
      end
    end

    it_behaves_like 'bidirectional transformers in multiple formats'
  end

end
