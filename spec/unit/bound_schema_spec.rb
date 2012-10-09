require_relative '../helper'

describe Gangsta::BoundSchema do

  context 'simple schema with passthrough' do
    before(:all) do
      class Post
        attr_accessor :author_email, :body, :excerpt
      end
    end
    let(:schema) { Gangsta::Schema.new(name: :post, classname: 'Test').tap do |s|
        s.definer.instance_eval do
          author do
            author_email
          end
          body
          excerpt
        end
      end
    }
    let(:post) { Post.new.tap do |p|
        p.author_email = 'a@b.com'
        p.body = "This is the body."
        p.excerpt = "This is the..."
      end
    }
    let(:bs) { schema.bound_to(post) }

    it 'can get the values from the bound object' do
      bs.bound_object.should == post
      #bs.value.should == post
      
      bs[:body].value.should == 'This is the body.'
      bs[:excerpt].value.should == 'This is the...'
      bs[:author][:author_email].value.should == 'a@b.com'
    end
  end

  context 'multiple object schema' do
    before(:all) do
      class Post
        attr_accessor :author, :body, :excerpt
      end
      class Author
        attr_accessor :email
      end
    end
    let(:schema) { Gangsta::Schema.new(name: :post, classname: 'Post').tap do |s|
        s.definer.instance_eval do
          author classname: 'Author' do
            author_email getter: :email, setter: :email=
          end
          body
          excerpt
        end
      end
    }
    let(:post) { Post.new.tap do |p|
        p.body = "This is the body."
        p.excerpt = "This is the..."
        p.author = Author.new.tap do |a|
          a.email = 'a@b.com'
        end
      end
    }
    let(:bs) { schema.bound_to(post) }

    it 'should get the values from the proper objects' do
      bs.bound_object.should == post
      Author.should === bs[:author].value
      bs[:author][:author_email].value.should == 'a@b.com'
    end

    it 'should set values on proper objects' do
      ns = schema.bound_to(Post.new)

      # easy part
      ns[:body].set_value("New Body")
      ns[:excerpt].set_value("New Excerpt")
      p = ns.bound_object
      p.body.should == "New Body"
      p.excerpt.should == "New Excerpt"

      # hard part: if we try to set a value on the author and it's nil, add one and then set it
      ns[:author][:author_email].set_value("au@thor.com")
      Author.should === ns[:author].value
      ns[:author].value.email.should == 'au@thor.com'

    end
  end

  context 'schema with list' do
    before(:all) do
      class Post
        attr_accessor :author, :body
        attr_accessor :comments
      end
    end

    let(:schema) { Gangsta::Schema.new(name: :post, classname: 'Post').tap do |s|
        s.definer.instance_eval do
          author
          body
          comments type: :list do
            comment do
              text
            end
          end
        end
      end
    }
    let(:post) { Post.new.tap do |p|
        p.author_email = 'a@b.com'
        p.body = "This is the body."
        p.comments = ['one comment, ah ah ah.', 'two comments, ah ah ah']
      end
    }
  end

end
