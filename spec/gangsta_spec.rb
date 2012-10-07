require 'helper'

describe Gangsta do
  context "basic reading and writing" do
    before do
      class TestClass 
        include Gangsta

        attr_accessor :id, :name
        def initialize(id, name)
          @id = id
          @name = name
        end

        gangsta do
          id
          name
        end

        def ==(another)
          self.id == another.id && self.name == another.name
        end
      end

      class TestClass2 < TestClass

        def self.default_initialization_args
          [nil,nil]
        end
      end
    end

    it 'should serialize with default transformer' do
      TestClass.new("crazy_id", "crazy_name").as_gangsta.should == "id is crazy_id\nname is crazy_name"
    end

    it 'should be bidirectional' do
      first = TestClass2.new("crazy_id", "crazy_name")
      string = first.as_gangsta
      second = TestClass2.gangstify(string)
      first.should == second
    end

    it 'should read from passed-in initialization args if given' do
      first = TestClass.new("identifier", "Pretty Name")
      string = first.as_gangsta

      second = TestClass.gangstify(string, initialization_args: ['over','ridden'])

      first.should == second
    end

    it 'should not fail if there is not a writer method for an input' do
      string = "id is crazy_id\nname is crazy_name\nother_attribute is other_value"

      second = TestClass.gangstify(string, initialization_args: ['over','ridden'])

      second.id.should == 'crazy_id'
      second.name.should == 'crazy_name'
    end
  end

  context "with multiple dictionaries" do
    before do 
      class Post
        include Gangsta
        attr_accessor :title, :body

        def initialize
          super
          if block_given?
            yield self
          end
        end

        def excerpt
          body[0..5] + '...'
        end

        gangsta :compact do
          title
          excerpt
        end

        gangsta :full do
          title
          body
        end

      end
    end

    let(:post) { Post.new do |p|
        p.title = "How to make a blog"
        p.body = "Step one: install rails. Step two: No step two!"
      end
    }

    it 'should serialize the specified dictionary' do
      
      post.as_gangsta(dictionary: :compact).should == "title is How to make a blog\nexcerpt is Step o..."
      post.as_gangsta(dictionary: :full).should == "title is How to make a blog\nbody is Step one: install rails. Step two: No step two!"

    end

    context "with subclass overriding a dictionary" do
      before do
        class BriefPost < Post
          gangsta :compact do
            title
          end
        end
      end
      let(:briefpost){BriefPost.new do |p|
          p.title = post.title
          p.body = post.body
        end
      }
      it "should use the child's dictionary" do
        briefpost.as_gangsta(dictionary: :compact).should == "title is How to make a blog"
      end
    end

  end
end
