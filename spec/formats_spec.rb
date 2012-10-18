require 'helper'


shared_examples 'bidirectional transformers in multiple formats' do

  it 'should serialize to simple XML and back again' do
    before = post
    # pp "before:"
    # pp post
    xml = post.as_gangsta(format: :simple_xml)
    # pp "xml:"
    # puts xml
    after = Post.gangstify(xml, format: :simple_xml)
    # pp "after:"
    # pp after
    before.should == after
  end

  it 'should serialize to simple JSON and back again' do
    before = post
    # pp "before:"
    # pp post
    json = post.as_gangsta(format: :simple_json)
    # pp "json:"
    # puts json
    after = Post.gangstify(json, format: :simple_json)
    # pp "after:"
    # pp after
    before.should == after
  end
end

describe Gangsta do
  context "simple schema" do

    before(:all) do
      class Post
        include Gangsta
        attr_accessor :title, :body, :author_email
        gangsta do
          title
          body 
          author_email
        end
        
        def ==(another)
          title == another.title &&
            body == another.body &&
            author_email == another.author_email
        end
        
      end
    end
    after(:all) do
      Object.send :remove_const, :Post
    end

    let(:post) { Post.new.tap do |p|
        p.title = "This is the title"
        p.body = "This is the body"
        p.author_email = "author@example.com"
      end
    }

    it_behaves_like 'bidirectional transformers in multiple formats'
  end
  
  context 'nested schema' do
    before(:all) do
      class Post
        include Gangsta
        attr_accessor :title, :body, :author_email, :author_name, :comments

        gangsta do
          title
          body
          author_info do
            author_name
            author_email
          end

          comments reader: :my_comments, type: :list do
            comment classname: 'Comment' do
              text
              author
            end
          end
        end
        
        def my_comments
          @comments ||= []
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
    after(:all) do
      Object.send :remove_const, :Post
      Object.send :remove_const, :Comment
    end

    let(:post) { Post.new.tap do |p|
        p.title = "This is the title"
        p.body = "This is the body"
        p.author_email = "author@example.com"
        p.author_name = "Yer Mom"
        
        p.comments = ['uno', 'dos', 'tres'].map do |txt|
          Comment.new.tap do |c|
            c.text = txt
            c.author = "anonymous #{txt}"
          end
        end
      end
    }

    it_behaves_like 'bidirectional transformers in multiple formats'
  end

end
