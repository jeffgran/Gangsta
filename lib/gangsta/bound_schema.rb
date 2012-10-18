require_relative 'schema.rb'

module Gangsta
  require 'delegate'

  class SchemaNotBound < StandardError; end
  class SchemaAlreadyBound < StandardError; end
  class InvalidSchema < StandardError; end

  class BoundSchema
    include SchemaTree
    include Enumerable
    
    attr_reader :schema
    delegate :name, :reader, :writer, :classname, :type, :namespace, :namespaces, :qname, :uri, to: :schema

    def initialize(schema, object, parent)
      @schema = schema
      @bound_object = object
      @parent = parent

      @bound_object = if (o = parent.try(:value))
                        #puts "we will be calling #{self.reader} on #{o}"
                        o
                      else
                        object
                      end
    end

    def each
      children.each{|item| yield item}
    end

    def size
      children.size
    end

    def children
      # lazy deep clone
      @children ||= schema.children.map do |c|
        # bind to nil so that it still goes up the chain
        # when we ask for the bound object of a distant leaf
        c.bound_to(nil, self)
      end
    end

    def bound_to(obj)
      raise SchemaAlreadyBound
    end

    def bound_object
      @bound_object || parent.try(:bound_object) || (raise SchemaNotBound, 'wtf?')
    end

    def bind_object(obj)
      @bound_object = obj
    end

    def bound?
      !bound_object.nil?
    end

    def loosely_bound?
      @bound_object.nil?
    end

    def value
      self.schema.value ||
      if self.root?
        # nothing
      elsif !self.bound_object.respond_to?(reader)
        puts "warning: #{self.bound_object} does not respond to reader #{reader}. returning nil."
        nil
      else
        self.bound_object.send(reader)
      end
    end

    def set_value(val)
      if bound_object.respond_to?(writer)
        bound_object.send(writer, val)
      elsif parent.loosely_bound? and parent.classname and !parent.root?
        obj = parent.classname.constantize.new
        parent.set_value(obj)
        @bound_object = obj
        bound_object.send(writer, val)
      end

    end
  end

  class BoundList < BoundSchema

    def children
      @children ||= (self.value || []).tap do |c|
        raise TypeError, "Gangsta: list schema got #{c} instead of an enumerable." unless c.respond_to? :map
      end.map do |object|
        schema.child.bound_to(object)
      end
    end

    def leaf?
      false # empty children for a newly bound list makes this seem like a leaf but it's not
    end

    def child
      children.first
    end

    def add(obj)
      children << schema.child.bound_to(obj)
    end

    def build_child
      @children ||= [] # needed to accomodate the lazy loaded children when calling build_child if @children is sitll nil
      obj = schema.child.classname.constantize.new
      value << obj
      add(obj)
      obj
    rescue NameError => e
      raise InvalidSchema, "In schema #{root.name} for #{root.class.to_s}, error trying to instantiate new #{schema.child.classname}: class does not exist! (#{e.inspect}, #{e.message})"
    end

    def [](num)
      raise ArgumentError, "List Schemas respond to [0], not [:name]" unless num.is_a?(Fixnum)
      children[num]
    end
  end
end
