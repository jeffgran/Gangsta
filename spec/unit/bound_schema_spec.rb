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
      bs.value.should == post
      
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
    let(:schema) { Gangsta::Schema.new(name: :post, classname: 'Test').tap do |s|
        s.definer.instance_eval do
          author do
            author_email getter: :email
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
  end
  
end
