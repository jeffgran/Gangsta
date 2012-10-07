module Gangsta
  class Definer < ::BasicObject
    def initialize(dictionary)
      @dictionary = dictionary
    end

    def object_id
      __id__
    end

    def method_missing(sym, *args)
      if args.empty?
        @dictionary.add_definition(sym)
      elsif args.first.is_a? ::Hash 
        @dictionary.add_definition(sym, args.first)
      else
        #raise ::ArgumentError, "please pass a hash of options"
      end
    end
  end

  require 'delegate'
  class Dictionary

    def initialize(klass)
      @class = klass
    end

    def bound_to(instance)
      BoundDictionary.new(self, instance)
    end
    
    def definer
      Definer.new(self)
    end

    def root_node_name
      @root_node_name ||= @class.to_s.underscore
    end

    def definitions
      @definitions ||= []
    end

    def has_definition_for?(name)
      definitions.map(&:name).include?(name)
    end

    def add_definition(name, options={})
      #pp "adding definition #{name} #{options[:getter]}"
      definitions << Definition.new(self, name, options)
      #pp self
    end

    def vocabs
      definitions.map(&:vocab)
    end
  end

    class BoundDictionary < DelegateClass(Dictionary)
      attr_reader :bound_object
      def initialize(dictionary, instance)
        super(dictionary)
        @bound_object = instance
      end
      def definitions
        super.map do |attr|
          attr.bound_to(@bound_object)
        end
      end

      def set_value(name, value, options={})
        setter = "#{name}=".to_sym
      
        if (@bound_object.respond_to? setter) &&
            (self.has_definition_for?(name.to_sym))
          @bound_object.send(setter, value)
        end
      end
    end

  class Definition
    attr_accessor :getter, :name, :vocab, :type

    def initialize(dictionary, name, options)
      @dictionary = dictionary
      self.vocab = options[:vocab]
      self.name = name.to_sym

      if block_given?
        options[:type] ||= :array
        
      else
        self.getter = name.to_sym
      end
    end

    def bound_to(instance)
      BoundDefinition.new(self, instance)
    end

    def value
      raise DictionaryNotBound, "can't get value for #{name}, this dictionary is not bound to an instance, only to a class."
    end
  end

  class BoundDefinition < DelegateClass(Definition)
    attr_reader :bound_object
    def initialize(definition, instance)
      super(definition)
      @bound_object = instance
    end

    def value
      @bound_object.send(getter)
    end
  end

  # librarian holds the dictionary for an object instance
  # could be called ObjectProxy but this is more descriptive maybe?
  class Librarian
    def initialize(obj, dict)
      @object = obj
      @dictionary = dict
    end
  end
end
