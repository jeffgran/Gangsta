module Gangsta
  class SimpleTransformer < Transformer
    def serialize(dictionary)
      out = []
      dictionary.definitions.each do |attr|
        name = if attr.vocab
                 "#{attr.vocab}:#{attr.name}"
               else
                 attr.name
               end
        out << "#{name} is #{attr.value}"
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
