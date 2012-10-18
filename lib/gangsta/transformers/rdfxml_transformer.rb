module Gangsta
  class RdfTransformerBase < Transformer

    def serialize(schema)
      @graph = ::RDF::Graph.new
      build_tree(schema)
    end

    def build_tree(schema)
      # puts '---'
      # puts "build_tree(#{schema.name})"
      # puts "leaf: #{schema.leaf?}"
      # puts "value: #{schema.value}"
      # puts "children: #{schema.children.size}"
      unless schema.loosely_bound?
        @graph << [RDF::URI(schema.uri), RDF.type, RDF::URI("#{schema.namespaces[schema.namespace]}#{schema.name}")]
      end

      if object = schema.value
        # pp predicate
        # pp schema.name
        # pp schema.value
        subject = RDF::URI("#{schema.root[:uri]}")
        predicate = RDF::URI("#{schema.namespaces[schema.namespace]}#{schema.name}")
        #TODO should not necessarily be schema.root -- it should be the nearest non-loosely bound ancestor schema
        @graph << [RDF::URI(schema.root.uri), predicate, object]
      end
      schema.children.each do |c|
        build_tree(c)
      end
    end
  end

  class RdfTransformer < RdfTransformerBase
    def serialize(dictionary)
      super

    end

  end

  class RdfxmlTransformer < RdfTransformerBase
    def serialize(schema)
      super

      RDF::RDFXML::Writer.buffer(:prefixes => schema.namespaces) do |writer|
        @graph.each_statement do |statement|
          writer << statement
        end
      end
    end

    def deserialize(string, object_proxy)

      reader = ::RDF::RDFXML::Reader.new(string)
      reader.each_triple do |subject, predicate, object|
        # TODO object could be another graph, not necessarily a string literal
        value = object.to_s
        object_proxy.set_value(predicate.qname[1], value, vocab: predicate.qname[0])
      end
    end
  end
end
