require 'nokogiri'

module Gangsta
  class SimpleXmlTransformer < Transformer
    def serialize(schema)
      builder = Nokogiri::XML::Builder.new do |xml|
        build_tree(schema, xml)
      end
      builder.to_xml
    end

    def build_tree(schema, xml)

      xml.send("#{schema.name}_") do
        schema.children.each do |s|
          if s.leaf?
            xml.send("#{s.name}_") { xml.text(s.value)  }
          else
            build_tree(s, xml)
          end
        end
      end
    end

    def deserialize(string, schema)
      doc = Nokogiri::XML::Document.parse(string)


      deserialize_tree(doc.root, schema)
    end

    def deserialize_schema(node, schema)
      if schema.type == :list
        deserialize_list(node, schema)
      elsif schema.leaf?
        #puts "  #{schema.name} . set_value (#{node.text})" 
        schema.set_value(node.text)
      else
        deserialize_tree(node, schema)
      end
    end

    def deserialize_list(node, schema)
      # pp "in list!!!!!!!!!!!!!!!!!!"
      # pp node.name
      # pp schema.name
      node.element_children.each_with_index do |elem, i|
        #puts "building child. before, size is #{schema.size}"
        schema.build_child
        # puts "building child. after, size is #{schema.size}"
        # puts "going to deserialize #{elem.name} xml elemnt to schema: #{schema[i].name}"
        deserialize_tree(elem, schema[i])
      end
    end

    def deserialize_tree(node, schema)
      node.element_children.each do |node|

        next if node.text?

        if test = schema[node.name.to_sym]
          schema = test

          deserialize_schema(node, schema)

          schema = schema.parent
        end
      end
    end
  end
end
