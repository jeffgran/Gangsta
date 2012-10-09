module Gangsta
  class Binder
    class << self
      def for(definable)
        #pp "Checking list? for #{definable.name}:"
        # pp definable.parent.name rescue nil
        # pp definable.parent.getter rescue nil
        # pp definable.bound_object rescue nil
        # if (g = definable.getter) &&
        #     ((bo = definable.bound_object).respond_to?(g))
        #     (arr = bo.send(g)).is_a?(Array)
        if definable.type == :list
          #puts "binding list #{arr} to #{definable.name}"
          ListBinder.new(definable, definable.value)
        elsif definable.type == :passthrough
          PassthroughBinder.new(definable)
        else
          puts "binding default #{definable.name}"
          DefaultBinder.new(definable)
        end
      end
    end
    attr_reader :definable
    def initialize(definable)
      @definable = definable
    end
  end

  class DefaultBinder < Binder

    def dictionaries(dictionaries)
      dictionaries.map do |dict|
        puts "binding dict #{dict.name} to #{definable.bound_object}"
        dict.bound_to(definable.bound_object)
      end
    end

    def definitions(definitions)
      definitions.map do |attr|
        puts "in default binder, binding #{attr.name} to #{definable.bound_object}"
        attr.bound_to(definable.bound_object)
      end
    end
  end

  class ListBinder < Binder
    attr_accessor :list
    def initialize(definable, list)
      @list = list
      super(definable)
    end

    def dictionaries(dictionaries)
      puts "binding dictionaries in list binder for #{definable.name}"
      puts "  (#{dictionaries.size}): #{dictionaries.map(&:name)}"
      dictionaries.map do |dict|
        list.map do |elem|
          bd = dict.bound_to(elem)
          puts "Looping: binding dict #{bd.name} to #{elem}"
          bd
        end
      end.tap do |d|
        # pp d.size
        # pp d
      end.flatten
    end

    def definitions(definitions)
      puts "binding definitions in list binder for #{definable.name}"
      puts "  (#{definitions.size}): #{definitions.map(&:name)}"
      definitions.map do |attr|
        list.map do |elem|
          bd = attr.bound_to(elem)
        end
      end.tap do |d|
        # pp d
      end.flatten
    end

  end

  class PassthroughBinder < Binder
    
    def definitions(definitions)
      definitions.map do |attr|
        puts "binding passthrough #{attr.name} to #{definable.bound_object}"
        attr.bound_to(definable.bound_object)
      end.tap do |defs|
        definable.dictionaries.each do |dict|
          dict.definitions.each do |attr|
            defs << attr.bound_to(definable.bound_object)
          end
        end
        # if definable.parent
        #   puts "adding parent definitions"
        #   definable.parent.definitions.each do |attr|
        #     defs <<  attr.bound_to(definable.bound_object)
        #   end
        # end
      end
    end

    def dictionaries(dictionaries)
      puts '*** in passthrough binder #dictionaries'
      dictionaries.map do |dict|
        puts "binding dict #{dict.name} to #{definable.bound_object}"
        dict.bound_to(definable.bound_object)
      end.tap do |dicts|
        dicts.each do |dict|
          dict.dictionaries.each do |attr|
            defs << attr.bound_to(definable.bound_object)
          end
        end
      end
    end
  end

end
