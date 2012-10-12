require_relative '../helper'

describe Gangsta::BoundSchema do




  context 'simple schema with passthrough' do

    before(:all) do
      class Post
        attr_accessor :author_email, :body, :excerpt
      end
    end

    after(:all) do
      Object.send :remove_const, :Post
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

    after(:all) do
      Object.send :remove_const, :Post
      Object.send :remove_const, :Author
    end


    let(:schema) { Gangsta::Schema.new(name: :post, classname: 'Post').tap do |s|
        s.definer.instance_eval do
          author classname: 'Author' do
            author_email accessor: :email
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
        attr_accessor :author_email, :body
        attr_accessor :comments
      end
      class Comment
        attr_accessor :text
        def initialize(options={})
          @text = options[:text]
        end
      end
    end

    after(:all) do
      Object.send :remove_const, :Post
      Object.send :remove_const, :Comment
    end


    let(:schema) { Gangsta::Schema.new(name: :post, classname: 'Post').tap do |s|
        s.definer.instance_eval do
          author reader: :author_email, writer: :author_email=
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
        p.comments = [Comment.new(text:'one comment, ah ah ah.'), Comment.new(text:'two comments, ah ah ah')]
      end
    }

    let(:bs) {schema.bound_to(post)}

    it 'can get the values from the list' do
      bs[:author].value.should == 'a@b.com'
      
      # get the literal value of Post#comments
      bs[:comments].value.size.should == 2

      # get the iterator for the list schema, which should
      # return a bound schema for each child of the actual array
      bs[:comments].size.should == 2
      bs[:comments].each_with_index do |c, i|
        c.name.should == :comment
        c.bound_object.should == post.comments[i]
        c[:text].value.should == post.comments[i].text
      end
    end


    it 'can set multiple values for a list' do
      ns = schema.bound_to(Post.new)

      ns[:comments].add Comment.new
      ns[:comments][0][:text].set_value('first!')

      ns[:comments].add Comment.new(text: 'dang :(')

      ns[:comments].size.should == 2
      ns[:comments][0][:text].value.should == 'first!'
      ns[:comments][1][:text].value.should == 'dang :('

      ns[:comments][1][:text].set_value('edit')
      ns[:comments][1][:text].value.should == 'edit'
    end
  end

end
