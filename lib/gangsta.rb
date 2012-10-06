require 'blankslate'
require 'pp'
require 'active_support/inflector'
Dir.glob(File.dirname(__FILE__) + '/gangsta/*') {|f| require f}

module Gangsta
  def self.included(base)
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
  end


  module ClassMethods

    def gangsta_dictionaries
      parent_dicts = (self.superclass.gangsta_dictionaries rescue {}) || {}
      @gangsta_dictionaries ||= {}
      @gangsta_dictionaries = parent_dicts.merge(@gangsta_dictionaries)
    end
    protected :gangsta_dictionaries
    
    def gangsta(*args, &block)
      dict_name, options = if args.first.is_a? Symbol
                             [args[0], (args[1] || {})]
                           elsif args.first.is_a? Hash
                             [nil, args.first]
                           elsif args.empty?
                             [nil, {}]
                           else
                             puts "warning... don't understand arguments to #gangsta. using defaults."
                           end

      dict_name ||= (options[:dictionary] || :default)

      dict = if block_given?
               gangsta_dictionaries[dict_name] = Dictionary.new.tap do |d|
                 d.definer.instance_eval(&block)
               end
             else
               gangsta_dictionaries[dict_name]
             end

      dict
    end


    def gangstify(string, options={})
      options = {transformer: :simple, dictionary: :default}.merge(options)
      init_args = options[:initialization_args] || (self.respond_to?(:default_initialization_args) ? default_initialization_args : nil)

      obj = if init_args
              self.new(*init_args)
            else
              self.new
            end

      proxy = ::Gangsta::Librarian.new(obj, self.gangsta(dictionary: options[:dictionary]))

      ::Gangsta::Transformer.from_sym(options[:transformer]).deserialize(string, proxy)
      obj
    end
  end

  module InstanceMethods
    def as_gangsta(options={})
      #defaults
      options = {transformer: :simple, dictionary: :default}.merge(options)

      ::Gangsta::Transformer.from_sym(options[:transformer]).serialize(self, self.class.gangsta(dictionary: options[:dictionary]))

    end
  end

end

