module Gangsta
  class Definer < ::BasicObject
    def initialize(dictionary)
      @dictionary = dictionary
    end

    def method_missing(sym, *args, &block)
      raise ArgumentError unless (opts = (args.first || {})).is_a? ::Hash
      opts = {name: sym}.merge(opts)
      @dictionary.add_definable(opts, &block)
    end
  end
end
