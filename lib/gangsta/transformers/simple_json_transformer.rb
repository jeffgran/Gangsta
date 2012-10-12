require 'jsonify'
require 'json'
module Gangsta
  class SimpleJsonTransformer < Transformer
    def serialize(schema)
      #::Jsonify::Builder.compile do |j|
      out = ::Jsonify::Builder.pretty do |j|
        build_tree(schema, j)
      end
    end

    def build_tree(schema, json)

      json.tag!(schema.name) do
        schema.children.each do |s|
          if s.leaf?
            json.tag!(s.name, s.value)
          elsif s.type == :list
            json.send(s.name, s.children) do |c|
              build_tree(c,json)
            end
          else
            build_tree(s, json)
          end
        end
      end
    end

    def deserialize(string, schema)
      json = ::JSON.parse(string)
      raise InvalidSchema unless json.keys.size == 1 and json.keys.first.to_sym == schema.name
      deserialize_schema(json[schema.name.to_s], schema)
    end

    def deserialize_schema(json, schema)
      if json.nil?
        return nil
      elsif schema.type == :list
        return nil unless json.is_a? Array
        deserialize_array(json, schema)
      elsif schema.leaf?
        schema.set_value(json)
      else
        deserialize_hash(json, schema)
      end
    end

    def deserialize_array(arr, schema)
      # pp "in list!!!!!!!!!!!!!!!!!!"
      # pp node.name
      # pp schema.name
      arr.each_with_index do |elem, i|
        # puts "building child. before, size is #{schema.size}"
        schema.build_child
        # puts "building child. after, size is #{schema.size}"
        # puts "going to deserialize #{elem.to_s} xml elemnt to schema: #{schema[i].name}"
        # pp elem[schema[i].name.to_s]
        deserialize_schema(elem[schema[i].name.to_s], schema[i])
      end
    end

    def deserialize_hash(hash, schema)
      hash.each do |key, value|

        if test = schema[key.to_sym]
          schema = test

          # puts "Processing node (#{key}: #{value})"
          # puts "   - current schema name: #{schema.name}"
          deserialize_schema(value, schema)

          schema = schema.parent
        end
      end
    end
  end
end
