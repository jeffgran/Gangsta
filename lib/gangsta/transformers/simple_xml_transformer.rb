module Gangsta
  class SimpleXmlTransformer < Transformer
    def serialize(dictionary)
      builder = Nokogiri::XML::Builder.new do |xml|
        #xmlnss = dictionary.vocabs.map{|v|  }
        xml.send dictionary.root_node_name do
          dictionary.definitions.each do |attr|
            xml.send(attr.name) { xml.text attr.value }
          end
        end
      end

      builder.to_xml
    end

    def deserialize(string, object_proxy)
      doc = Nokogiri::XML::Document.parse(string)
      doc.root.children.each do |node|
        object_proxy.set_value(node.name, node.text)
      end
    end
  end
end
