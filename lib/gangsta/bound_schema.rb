require_relative 'schema.rb'

module Gangsta
  require 'delegate'

  class SchemaNotBound < StandardError; end
  class SchemaAlreadyBound < StandardError; end

  class BoundSchema# < DelegateClass(Schema)
    include SchemaTree
    
    attr_reader :schema
    delegate :name, :getter, :setter, :classname, to: :schema

    def initialize(schema, object, parent)
      @schema = schema
      @bound_object = object
      @parent = parent

      @bound_object = if (o = parent.try(:value))
                        #puts "we will be calling #{self.getter} on #{o}"
                        o
                      else
                        object
                      end

      # deep clone
      @children = schema.children.map do |c|
        # bind to nil so that it still goes up the chain
        # when we ask for the bound object of a distant leaf
        c.bound_to(nil, self)
      end
    end
    
    def self.build(schema, obj)

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
      if self.root?
        #self.bound_object
      elsif !self.bound_object.respond_to?(getter)
        puts "warning: #{self.bound_object} does not respond to getter #{getter}. returning nil."
        nil
      else
        self.bound_object.send(getter)
      end
    end

    def set_value(val)
      if bound_object.respond_to?(setter)
        bound_object.send(setter, val)
      elsif parent.loosely_bound? and parent.classname and !parent.root?
        obj = parent.classname.constantize.new
        parent.set_value(obj)
        @bound_object = obj
        bound_object.send(setter,val)
      end

    end
  end
end

# module Bindable
#   def self.included(base)
#     base.class_eval do

#     end
#   end

#   def binder
#     @binder = Binder.for(self)
#   end

# end
