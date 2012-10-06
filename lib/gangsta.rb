require 'blankslate'
require 'pp'
module Gangsta
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      include InstanceMethods
    end
  end


  module ClassMethods
    def gangsta(&block)
      @@_gangsta_dictionary = Dictionary.new
      @@_gangsta_dictionary.definer.instance_eval(&block)
    end
    def dictionary
      @@_gangsta_dictionary
    end
  end

  module InstanceMethods
    def gangsta_out(strategy=:to_s)

      self.class.dictionary.definitions.each do |word|
        name = if word.vocab
                 "#{word.vocab}:#{word.name}"
               else
                 word.name
               end
        puts "#{name} is \"#{send word.calculator_method}\""
      end
    end
  end

  class Definer < ::BlankSlate
    def initialize(dictionary)
      @dictionary = dictionary
    end
    
    def node(name, calculator, options={})
      @dictionary.definitions << Definition.new(name, calculator, options)
    end

    def method_missing(sym, *args)
      node(sym, *args)
    end
  end

  class Dictionary
    attr_accessor :definer

    def initialize
      @definer = Definer.new(self)
    end

    # just to keep the blank slate blank
    def definitions
      @definitions ||= []
    end

  end

  class Definition
    attr_accessor :calculator_method, :name, :vocab

    def initialize(name, calculator, options)
      self.vocab = options[:vocab]
      self.name = name
      self.calculator_method = calculator
    end

  end
end


class TestClass 
  include Gangsta

  gangsta do
    id :id
  end

  def id
    'my id'
  end

end

TestClass.new.gangsta_out
