module Gangsta
  class RdfTransformerBase < Transformer

    def serialize(dictionary)
      @graph = ::RDF::Graph.new
      vocabs = {}

      dictionary.definitions.each do |attr|
        vocabs[attr.vocab] ||= RDF::Vocabulary.new(attr.vocab)
        @graph << [attr.name, vocabs[attr.vocab][attr.name], attr.value]
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
