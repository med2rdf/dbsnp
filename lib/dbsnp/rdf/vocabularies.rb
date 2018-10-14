require 'rdf'
require 'rdf/vocab'

module DbSNP::RDF
  PREFIXES = {
    rdf:       ::RDF::RDFV.to_s,
    owl:       ::RDF::OWL.to_s,
    dc:        ::RDF::Vocab::DC.to_s,
    rdfs:      ::RDF::Vocab::RDFS.to_s,
    xsd:       ::RDF::Vocab::XSD.to_s,
    dbsnp:     'http://identifiers.org/dbsnp/',
    faldo:     'http://biohackathon.org/resource/faldo#',
    hco:       'http://identifiers.org/hco/',
    m2r:       'http://med2rdf.org/ontology/med2rdf#',
    ncbi_gene: 'http://identifiers.org/ncbigene/',
    obo:       'http://purl.obolibrary.org/obo/',
    refseq:    'http://identifiers.org/refseq/',
    sio:       'http://semanticscience.org/resource/',
    snpo:      'http://purl.jp/bio/10/dbsnp/',
    tax:       'http://identifiers.org/taxonomy/'
  }.freeze

  FALDO = RDF::Vocabulary.new(PREFIXES[:faldo])
  HCO   = RDF::Vocabulary.new(PREFIXES[:hco])
  M2R   = RDF::Vocabulary.new(PREFIXES[:m2r])
  OBO   = RDF::Vocabulary.new(PREFIXES[:obo])
  SIO   = RDF::Vocabulary.new(PREFIXES[:sio])

  class SNPO < RDF::StrictVocabulary(PREFIXES[:snpo])

    # Ontology definition
    ontology to_uri.freeze,
             type:             ::RDF::OWL.Ontology,
             :'dc:title'       => 'dbSNP Ontology',
             :'dc:description' => 'dbSNP Ontology describes classes and properties which is used in dbSNP RDF',
             :'owl:imports'    => [::RDF::Vocab::DC.to_s,
                                   FALDO.to_s,
                                   OBO.to_s,
                                   M2R.to_s].freeze

    # Class definitions
    term :Allele,
         type:        ::RDF::OWL.Class,
         subClassOf:  M2R.Variation.freeze,
         isDefinedBy: to_s.freeze,
         label:       'Allele'.freeze

    term :Frequency,
         type:        ::RDF::OWL.Class,
         isDefinedBy: to_s.freeze,
         label:       'Frequency'.freeze

    term :'1000GenomesFrequency',
         type:        ::RDF::OWL.Class,
         subClassOf:  self.Frequency,
         isDefinedBy: to_s.freeze,
         comment:     'Frequency of a minor allele reported by 1000Genomes',
         label:       '1000GenomesFrequency'.freeze

    term :ALSPACFrequency,
         type:        ::RDF::OWL.Class,
         subClassOf:  self.Frequency,
         isDefinedBy: to_s.freeze,
         comment:     'Frequency of a minor allele reported by ALSPAC',
         label:       'ALSPACFrequency'.freeze

    term :GoESPFrequency,
         type:        ::RDF::OWL.Class,
         subClassOf:  self.Frequency,
         isDefinedBy: to_s.freeze,
         comment:     'Frequency of a minor allele reported by GoESPF',
         label:       'GoESPFrequency'.freeze

    term :ExACFrequency,
         type:        ::RDF::OWL.Class,
         subClassOf:  self.Frequency,
         isDefinedBy: to_s.freeze,
         comment:     'Frequency of a minor allele reported by ExAC',
         label:       'ExACFrequency'.freeze

    term :GnomADFrequency,
         type:        ::RDF::OWL.Class,
         subClassOf:  self.Frequency,
         isDefinedBy: to_s.freeze,
         comment:     'Frequency of a minor allele reported by GnomAD',
         label:       'GnomADFrequency'.freeze

    term :GnomAD_exomesFrequency,
         type:        ::RDF::OWL.Class,
         subClassOf:  self.Frequency,
         isDefinedBy: to_s.freeze,
         comment:     'Frequency of a minor allele reported by GnomAD_exomes',
         label:       'GnomAD_exomesFrequency'.freeze

    term :TOPMEDFrequency,
         type:        ::RDF::OWL.Class,
         subClassOf:  self.Frequency,
         isDefinedBy: to_s.freeze,
         comment:     'Frequency of a minor allele reported by TOPMED',
         label:       'TOPMEDFrequency'.freeze

    term :TWINSUKFrequency,
         type:        ::RDF::OWL.Class,
         subClassOf:  self.Frequency,
         isDefinedBy: to_s.freeze,
         comment:     'Frequency of a minor allele reported by TWINSUK',
         label:       'TWINSUKFrequency'.freeze

    # Property definitions
    property(:clinical_significance,
             type:        ::RDF::OWL.DatatypeProperty,
             label:       'clinical_significance'.freeze,
             domain:      SNPO.Allele,
             isDefinedBy: to_s.freeze,
             range:       ::RDF::XSD.string
    )

    property(:build,
             type:        ::RDF::OWL.DatatypeProperty,
             label:       'build'.freeze,
             isDefinedBy: to_s.freeze,
             domain:      M2R.Variation,
             range:       ::RDF::XSD.string,
             comment:     'First dbSNP Build for RS'
    )
  end
end
