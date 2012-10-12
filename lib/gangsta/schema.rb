module Gangsta
  module SchemaTree
    def self.included(base)
      base.class_eval do
        attr_accessor :parent
      end
    end

    def children
      @children ||= []
    end

    def [](sym)
      raise ArgumentError, "Schema responds to [:name], where :name is the name of the direct child schema you want" unless Symbol === sym
      children.select{|c|c.name == sym}.tap do |arr|
        return arr.first if arr.size == 1
        return nil if arr.size == 0
      end
    end

    def leaf?
      children.empty?
    end

    def leaves
      children.select(&:leaf?)
    end

    def bucket?
      !leaf?
    end

    def buckets
      children.select(&:bucket?)
    end

    def root
      parent.nil? ? self : parent.root
    end

    def root?
      parent.nil?
    end

    def show_tree(level=0)
      str = (" "*level) + "#{self.name}\n"
      self.definitions.each do |d|
        str += (" "*level) + " |-#{d.name} \n"
      end
      self.dictionaries.each do |dict|
        str += dict.tree(level+1)
      end
      str
    end

  end


  class Schema
    include RequireOptions
    include SchemaTree
    
    attr_accessor :name, :reader, :writer, :vocab, :type, :classname
    
    def initialize(options)
      allow_options(options, :class, :parent, :vocab, :name, :type, :reader, :writer, :accessor, :classname, :schema)

      # just assign both now that we know we don't have both.
      @class = options[:class]
      @parent = options[:parent]

      @name = (@class ? @class.to_s.underscore.to_sym : options[:name]).to_sym
      raise ArgumentError, "must supply :name to schema" if @name.nil?

      @vocab = options[:vocab].to_sym rescue nil
      @reader = options[:reader] || options[:accessor].try(:to_sym) || self.name
      @writer = options[:writer] || "#{options[:accessor] || self.name}=".to_sym
      @type = options[:type] || :obj
      @classname = options[:classname]
    end

    def bound_to(instance, parent=nil)
      if type == :list
        BoundList.new(self, instance, parent)
      else
        BoundSchema.new(self, instance, parent)
      end
    end

    def bound?
      false
    end

    def bound_object
      raise SchemaNotBound
    end

    def bind_object(obj)
      raise SchemaNotBound
    end

    def passthrough?
      type == :passthrough
    end

    def definer
      Definer.new(self)
    end

    def add_child_schema(options={}, &block)
      allow_options(options, :vocab, :name, :type, :reader, :writer, :classname, :accessor)

      #pp "adding definable #{options[:name]} to parent #{self.name}"

      options = {parent: self}.merge(options)

      klass = options[:type] == :list ? ListSchema : Schema

      self.children << child = klass.new(options).tap do |child|
        if block_given? # block means it's a container, not a leaf
          child.definer.instance_eval(&block)
        end
      end
      child
    end

  end


  class ListSchema < Schema
    def child
      children.first
    end

    def add_child_schema(options={}, &block)
      require_options(options, :name)
      raise InvalidSchemaError, "list `#{options[:name]}` cannot have more than one child. The child will represent each member of the list" if children.size > 0
      super
    end

  end

end
