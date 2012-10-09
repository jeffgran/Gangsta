module Gangsta
  class SimpleXmlTransformer < Transformer
    def serialize(dictionary)
      builder = Nokogiri::XML::Builder.new do |xml|
        build_dict(dictionary, xml)
      end

      builder.to_xml
    end

    def build_dict(dictionary, xml)

      xml.send("#{dictionary.name}_") do
        dictionary.definitions.each do |attr|
          #pp "trying to get value for #{attr.name} while looping through #{dictionary.name} definitions"
          xml.send("#{attr.name}_") { xml.text(attr.value)  }
        end
        dictionary.dictionaries.each do |dict|
          build_dict(dict, xml)
        end
      end
    end

    def deserialize(string, dictionary)
      doc = Nokogiri::XML::Document.parse(string)
      @current_path = [doc.root.name]
      deserialize_node(doc.root, dictionary)
    end

    def deserialize_node(parent, dictionary)
      parent.element_children.each do |node|
        next if node.text?
        @current_path.push(node.name)

        pp "Processing node (#{node.name}: #{node.text})"
        puts "   - current path: #{@current_path}"
        dictionary.set_value(@current_path, node.text)

        if node.element_children.any?
          deserialize_node(node, dictionary)
        end

        @current_path.pop
      end
    end
  end
end
