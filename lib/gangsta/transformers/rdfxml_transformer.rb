module Gangsta
  class RdfTransformerBase < Transformer

    def serialize(schema)
      @graph = ::RDF::Graph.new
      @vocabs = {}
      schema.children.each do |s|
        build_tree(s)
      end
    end

    def build_tree(schema)
      @vocabs[schema.vocab] ||= RDF::Vocabulary.new(schema.vocab)
      if schema.leaf?
        # pp schema.name
        # pp @vocabs[schema.vocab][schema.name]
        # pp schema.value
        @graph << [schema.name, @vocabs[schema.vocab][schema.name], schema.value]
      else
        build_tree(c)
      end
    end
  end

  class RdfTransformer < RdfTransformerBase
    def serialize(dictionary)
      super
      @graph
    end

  end

  class RdfxmlTransformer < RdfTransformerBase
    def serialize(dictionary)
      super
      @graph.dump(:rdfxml)
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
