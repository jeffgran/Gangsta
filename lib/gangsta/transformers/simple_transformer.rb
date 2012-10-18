module Gangsta
  class SimpleTransformer < Transformer
    def serialize(schema)
      out = []
      schema.children.each do |s|
        out << "#{s.qname} is #{s.value}"
      end
      out.join("\n")
    end

    def deserialize(string, schema)
      string.each_line do |line|
        name, value = line.strip.split(" is ")
        if s = schema[name.to_sym]
          s.set_value(value)
        end
      end
    end
  end
end
