require 'rdf'
require 'rdf/vocab'

module DbSNP::RDF
  module Vocabularies
    class M2r < RDF::StrictVocabulary(PREFIXES[:m2r])
      term :Variation

      property :gene
      property :reference_allele
      property :alternative_allele
    end

    class Obo < RDF::StrictVocabulary(PREFIXES[:obo])
      term :SO_0001483
      term :SO_1000032
      term :SO_0000289
      term :SO_0002007
      term :SO_0000159
      term :SO_0000667
    end

    class Snpo < RDF::StrictVocabulary(PREFIXES[:snpo])
      property :hgvs
      property :frequency
      property :sample_size
      property :clinical_significance
    end

    class Faldo < RDF::StrictVocabulary(PREFIXES[:faldo])
      term :ExactPosition

      property :location
      property :position
      property :reference
    end

    class DbSNP < RDF::StrictVocabulary(PREFIXES[:dbsnp])
      term(:RefSnp,
           type:        RDF::OWL.Class,
           label:       'refSNP',
           isDefinedBy: to_s.freeze,
           comment:     'A refSNP entry on dbSNP'.freeze
      )

      property(:taxonomy,
               type: RDF::OWL.ObjectProperty,
               label: 'taxonomy'.freeze,
               isDefinedBy: to_s.freeze,
               comment:  'taxonomy of the refSNP on dbSNP'.freeze,
               domain:  M2r.Variation,
               range:   RDF::Vocab::RDFS.Resource
      )
    end
  end
end