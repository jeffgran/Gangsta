module Gangsta
  class Schema
    include RequireOptions
    include SchemaTree
    
    attr_accessor :name, :reader, :writer, :type, :classname, :uri
    
    def initialize(options)
      allow_options(options, :class, :parent, :namespace, :name, :type, :reader, :writer, :accessor, :classname, :schema, :namespaces, :value, :uri)

      # just assign both now that we know we don't have both.
      @class = options[:class]
      @parent = options[:parent]

      @name = (@class ? @class.to_s.underscore.to_sym : options[:name]).to_sym
      raise ArgumentError, "must supply :name to schema" if @name.nil?

      @namespace = options[:namespace].to_sym rescue nil
      raise ArgumentError, ":namespaces must be a hash like {dc: 'http://purl.org/dc/terms/'}" unless 
        options[:namespaces].is_a? Hash or 
        options[:namespaces].blank?
      @namespaces = options[:namespaces]
      @reader = options[:reader] || options[:accessor].try(:to_sym) || self.name
      @writer = options[:writer] || "#{options[:accessor] || self.name}=".to_sym
      @value = options[:value]
      @type = options[:type] || :obj
      @classname = options[:classname]
      @uri = options[:uri]
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

    def value
      @value
    end

    def qname
      return self.name unless self.namespace
      "#{self.namespace}:#{self.name}"
    end

    def add_child_schema(options={}, &block)
      allow_options(options, :name, :type, :reader, :writer, :classname, :accessor, :namespace, :value)

      #pp "adding schema #{options[:name]} to parent #{self.name}"

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
