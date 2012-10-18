require 'helper'

describe Gangsta do
  context "rdf" do
    before(:all) do
      class Post
        include Gangsta
        attr_accessor :title, :body
        easy_initialize

        gangsta({
                  namespaces: {ex: 'http://example.com/terms/'}, 
                  namespace: :ex,
                  uri: "http://test.org/posts/1"
                }) do
          title
          body
        end

        # def ==(another)
        #   self.id == another.id && self.name == another.name
        # end
      end

    end
    let(:post) { Post.new(title: 'This is a Title', body: 'Here is some text.') }

    it 'serializes to rdf/xml' do
      lambda{post.as_gangsta(format: :rdfxml)}.should_not raise_error
    end

  end
end


class Object
  def self.easy_initialize
    self.class_eval do
      def initialize(opts={})
        opts.each do |key,val|
          self.instance_variable_set(:"@#{key}", val)
        end
      end
    end
  end
end
