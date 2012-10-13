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

    def namespaces
      @namespaces || parent.namespaces
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
end
