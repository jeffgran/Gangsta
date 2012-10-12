# Gangsta!
*(cuz I repreSENT!)*

## The State of the Gangsta

Gangsta is still experimental and in heavy flux. There are major feature holes and things that don't quite work. It's not ready for production use yet. Watch this space.

## Purpose

We had a problem. For our API (in a rails app), for each object type, we had:
* xml builder templates for xml content-type
* json_builder templates for json content-type
* custom params parser to convert xml POST and PUT into params hash
* In tests, a parallel mock class to serialize to xml using ROXML (in order to simulate POST)
* A separate RDF-based representation of certain objects

I see 4-5 places where we are storing the same information -- knowledge of the structure of the schema, and how to convert from:
* object <--> schema <--> representation


## Design Goals
* Simple, readable DSL for defining schemas
* Serialize/Deserialize from multiple formats
* Easy to write new "Transformers" to add new formats
* JSON and XML to start.
* JSON-LD and RDF/XML soon after.
* Compatibilty, but not dependence on Rails/ActiveRecord

Gangsta is not for everyone. The following tradeoffs are made in the design:

* flexibility of schema is less important than:
  * flexibility of interchangeable formats (serializing and deserializing)
  * dsl as simple and as readable as possible

## Example

Here's a couple of classes and a Gangsta schema:

```ruby
require 'gangsta'

class Post
  include Gangsta
  attr_accessor :title, :body, :comments
  
  def comments
    @comments ||= []
  end

  gangsta do
    title
    body
    comments type: :list do
      comment classname: 'Comment' do
        text
      end
    end
  end
end

class Comment
  attr_accessor :text
end

p = Post.new
p.title = "Hello"
p.body = "This is the body"
c1 = Comment.new
c1.text = "First!"
c2 = Comment.new
c2.text = "First! (Edit: dang.)"
p.comments = [c1,c2]
```

Here's what it can do:

```ruby
p.as_gangsta(format: :simple_xml)
```

###=>

```xml
<?xml version="1.0"?>
<post>
  <title>Hello</title>
  <body>This is the body</body>
  <comments>
    <comment>
      <text>First!</text>
    </comment>
    <comment>
      <text>First! (Edit: dang.)</text>
    </comment>
  </comments>
</post>
```

or:


```ruby
string = p.as_gangsta(format: :simple_json)
```

###=>

```javascript
{
  "post": {
    "title": "Hello",
    "body": "This is the body",
    "comments": [
      {
        "comment": {
          "text": "First!"
        }
      },
      {
        "comment": {
          "text": "First! (Edit: dang.)"
        }
      }
    ]
  }
}
```

And then it can consume that data with:

```ruby
Post.gangstify(string, format: :simple_json)
```

###=>

    #<Post:0x00000101180130 
      @title="Hello", 
      @body="This is the body", 
      @comments=[
        #<Comment:0x0000010117a078 @text="First!">, 
        #<Comment:0x00000101178ef8 @text="First! (Edit: dang.)">
      ]>


##Inspiration

* ROXML
* Representable
* And others

##Homage

Snoop Dogg: 

> "I'm not down with the republican party, or the democratic party. I represent the Gangsta party."

Larry King: 

> "The Gangsta party."

Snoop: 

> "Yes sir."



## Copyright

Copyright (c) 2012 Jeff Gran. See LICENSE.txt for
further details.

