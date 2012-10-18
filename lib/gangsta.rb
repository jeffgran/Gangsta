require 'blankslate'
require 'pp'
require 'active_support/inflector'
require 'active_support/core_ext'
require 'rdf'
require 'rdf/rdfxml'
require 'require_options'
require 'gangsta/schema_tree'
Dir.glob(File.dirname(__FILE__) + '/gangsta/**/*.rb') {|f| puts "requiring #{f}"; require f}

module Gangsta
  def self.included(base)
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods

    def gangsta(*args, &block)
      schema_name, options = if args.first.is_a? Symbol
                               [args[0], (args[1] || {})]
                             elsif args.first.is_a? Hash
                               [nil, args.first]
                             elsif args.empty?
                               [nil, {}]
                             else
                               puts "warning... don't understand arguments to #gangsta. using defaults."
                               [nil,nil]
                             end

      schema_name ||= (options[:schema] || :default)

      schema = if block_given?
                 gangsta_schemas[schema_name] = Schema.new(options.merge(:class => self)).tap do |d|
                   d.definer.instance_eval(&block)
                 end
               else
                 gangsta_schemas[schema_name]
               end

      schema
    end

    def gangsta_schemas
      parent_dicts = (self.superclass.gangsta_schemas rescue {}) || {}
      @gangsta_schemas ||= {}
      @gangsta_schemas = parent_dicts.merge(@gangsta_schemas)
    end
    protected :gangsta_schemas


    def gangstify(string, options={})
      options = {format: :simple, schema: :default}.merge(options)
      init_args = options[:initialization_args] || (self.respond_to?(:default_initialization_args) ? default_initialization_args : nil)

      obj = if init_args
              self.new(*init_args)
            else
              self.new
            end
      
      dict = self.gangsta(schema: options[:schema])

      bound_dict = dict.bound_to(obj)

      ::Gangsta::Transformer.from_sym(options[:format]).deserialize(string, bound_dict)
      obj
    end
  end

  module InstanceMethods
    def as_gangsta(options={})
      #defaults
      options = {format: :simple, schema: :default}.merge(options)
      trans = ::Gangsta::Transformer.from_sym(options[:format])
      schema = self.class.gangsta(schema: options[:schema])
      bound_schema = schema.bound_to(self)

      #debugger

      trans.serialize(bound_schema)

    end
  end

end

