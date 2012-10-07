require 'helper'

describe Gangsta do
  context "outputting different formats" do
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
    it 'should serialize to RDF/XML and back again' do
      before = post
      rdfxml = post.as_gangsta(format: :rdfxml)
      after = Post.gangstify(rdfxml, format: :rdfxml)
      before.should == after
    end

    it 'should serialize to simple XML and back again' do
      before = post
      xml = post.as_gangsta(format: :simple_xml)
      after = Post.gangstify(xml, format: :simple_xml)
      before.should == after
    end
  end
end
