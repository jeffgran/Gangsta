module Gangsta
  class Transformer
    
    class << self
      def from_sym(sym)
        "gangsta/#{sym}_transformer".camelize.constantize.new
      end
    end

    def serialize(dictionary)
      raise NotImplementedError
    end
    def deserialize(string)
      raise NotImplementedError
    end

  end
end
