module Gangsta
  class SimpleTransformer < Transformer
    def serialize(object, dictionary)
      out = []
      dictionary.definitions.each do |word|
        name = if word.vocab
                 "#{word.vocab}:#{word.name}"
               else
                 word.name
               end
        out << "#{name} is #{object.send word.calculator_method}"
      end
      out.join("\n")
    end

    def deserialize(string, object_proxy)
      string.each_line do |line|
        name, value = line.strip.split(" is ")
        object_proxy.set_value(name, value)
      end
    end
  end
end
