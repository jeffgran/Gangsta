module Gangsta
  class Definer < ::BasicObject
    def initialize(dictionary)
      @dictionary = dictionary
    end

    def object_id
      __id__
    end

    def method_missing(sym, *args)
      @dictionary.add_definition(sym, *args)
    end
  end

  class Dictionary

    def initialize
    end
    
    def definer # don't keep this hanging around -- blank slate should have a fleeting existence
      Definer.new(self)
    end

    def definitions
      @definitions ||= []
    end

    def has_definition_for?(name)
      definitions.map(&:name).include?(name)
    end

    def add_definition(name, calculator, options={})
      #pp "adding definition #{name} #{calculator}"
      definitions << Definition.new(name, calculator, options)
      #pp self
    end

  end

  class Definition
    attr_accessor :calculator_method, :name, :vocab

    def initialize(name, calculator, options)
      self.vocab = options[:vocab]
      self.name = name.to_sym
      self.calculator_method = calculator
    end
  end

  # librarian holds the dictionary for an object instance
  # could be called ObjectProxy but this is more descriptive maybe?
  class Librarian
    def initialize(obj, dict)
      @object = obj
      @dictionary = dict
    end

    def set_value(name, value)
      setter = "#{name}=".to_sym
      
      if (@object.respond_to? setter) &&
          (@dictionary.has_definition_for?(name.to_sym))
        @object.send(setter, value)
      end
    end
  end
end
