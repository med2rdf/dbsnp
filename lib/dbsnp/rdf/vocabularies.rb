require 'rdf'
require 'rdf/vocab'

module DbSNP::RDF
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

  class Faldo < RDF::StrictVocabulary(PREFIXES[:faldo])
    term :ExactPosition
    term :Region

    property :location
    property :position
    property :reference
    property :begin
    property :end
  end

  class SNPO < RDF::StrictVocabulary(PREFIXES[:snpo])

    # Ontology definition
    ontology to_uri.freeze,
             type:             ::RDF::OWL.Ontology,
             :'dc:title'       => 'dbSNP Ontology',
             :'dc:description' => 'dbSNP Ontology describes classes and properties which is used in DGIdb RDF',
             :'owl:imports'    => [::RDF::Vocab::DC.to_s,
                                   Faldo.to_s,
                                   Obo.to_s,
                                   M2r.to_s].freeze

    # Class definitions
    term :Frequency,
         type:        ::RDF::OWL.Class,
         isDefinedBy: to_s.freeze,
         comment:     'Frequency of a minor allele',
         label:       'Frequency'.freeze

    term :'1000GenomesFrequency',
         type:        ::RDF::OWL.Class,
         subClassOf:  self.Frequency,
         isDefinedBy: to_s.freeze,
         comment:     'Frequency of a minor allele reported by 1000Genomes ',
         label:       '1000GenomesFrequency'.freeze

    term :AlspacFrequency,
         type:        ::RDF::OWL.Class,
         subClassOf:  self.Frequency,
         isDefinedBy: to_s.freeze,
         comment:     'Frequency of a minor allele reported by ALSPAC ',
         label:       'AlspacFrequency'.freeze

    term :EspFrequency,
         type:        ::RDF::OWL.Class,
         subClassOf:  self.Frequency,
         isDefinedBy: to_s.freeze,
         comment:     'Frequency of a minor allele reported by ESP6500SI-V2 ',
         label:       'EspFrequency'.freeze

    term :ExacFrequency,
         type:        ::RDF::OWL.Class,
         subClassOf:  self.Frequency,
         isDefinedBy: to_s.freeze,
         comment:     'Frequency of a minor allele reported by ExAC ',
         label:       'ExacFrequency'.freeze

    term :GnomadFrequency,
         type:        ::RDF::OWL.Class,
         subClassOf:  self.Frequency,
         isDefinedBy: to_s.freeze,
         comment:     'Frequency of a minor allele reported by GnomAD ',
         label:       'GnomadFrequency'.freeze

    term :TopmedFrequency,
         type:        ::RDF::OWL.Class,
         subClassOf:  self.Frequency,
         isDefinedBy: to_s.freeze,
         comment:     'Frequency of a minor allele reported by TOPMED ',
         label:       'TopmedFrequency'.freeze

    term :TwinsukFrequency,
         type:        ::RDF::OWL.Class,
         subClassOf:  self.Frequency,
         isDefinedBy: to_s.freeze,
         comment:     'Frequency of a minor allele reported by TWINSUK ',
         label:       'TwinsukFrequency'.freeze

    # Property definitions
    property(:clinical_significance,
             type:        ::RDF::OWL.DatatypeProperty,
             label:       'clinical_significance'.freeze,
             domain:      M2r.Variation,
             isDefinedBy: to_s.freeze,
             range:       ::RDF::XSD.string
    )

    property(:frequency,
             type:        ::RDF::OWL.ObjectProperty,
             label:       'hgvs'.freeze,
             comment:     'frequency of a minor allele'.freeze,
             domain:      M2r.Variation,
             isDefinedBy: to_s.freeze,
             range:       self.Frequency
    )

    property(:hgvs,
             type:        ::RDF::OWL.DatatypeProperty,
             label:       'hgvs'.freeze,
             comment:     'representation in HGVS format'.freeze,
             domain:      M2r.Variation,
             isDefinedBy: to_s.freeze,
             range:       ::RDF::XSD.string
    )

    property(:taxonomy,
             type:        ::RDF::OWL.ObjectProperty,
             label:       'taxonomy'.freeze,
             domain:      M2r.Variation,
             isDefinedBy: to_s.freeze,
             range:       ::RDF::Vocab::RDFS.Resource
    )

    def self.prefixes
      PREFIXES.merge({
                         owl:  ::RDF::OWL.to_s.freeze,
                         rdfs: ::RDF::Vocab::RDFS.to_s.freeze
                     })
    end
  end
end