require 'rdf'
require 'rdf/vocab'

module DbSNP::RDF
  PREFIXES = {
    rdfs:     ::RDF::Vocab::RDFS.to_s,
    dc:       ::RDF::Vocab::DC.to_s,
    xsd:      ::RDF::Vocab::XSD.to_s,
    faldo:    'http://biohackathon.org/resource/faldo#',
    m2r:      'http://med2rdf.org/ontology/med2rdf#',
    obo:      'http://purl.obolibrary.org/obo/',
    sio:      'http://semanticscience.org/resource/',
    snpo:     'http://purl.jp/bio/10/dbsnp/',
    clinvar:  'http://identifiers.org/clinvar.record:',
    dbsnp:    'http://identifiers.org/dbsnp/',
    hco:      'http://identifiers.org/hco/',
    ncbigene: 'http://identifiers.org/ncbigene/',
    refseq:   'http://identifiers.org/refseq/',
    tax:      'http://identifiers.org/taxonomy/'
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
                                   M2R.to_s]

    # Class definitions
    term :Allele,
         type:        ::RDF::OWL.Class,
         subClassOf:  M2R.Variation,
         isDefinedBy: to_s,
         label:       'Allele'

    # Property definitions
    property(:is_created_in_build,
             type:        ::RDF::OWL.DatatypeProperty,
             label:       'is_created_in_build',
             isDefinedBy: to_s,
             domain:      M2R.Variation,
             range:       ::RDF::XSD.integer,
             comment:     'First dbSNP Build for RS'
    )

    property(:is_updated_in_build,
             type:        ::RDF::OWL.DatatypeProperty,
             label:       'is_updated_in_build',
             isDefinedBy: to_s,
             domain:      M2R.Variation,
             range:       ::RDF::XSD.integer,
             comment:     'Latest dbSNP Build for RS'
    )
  end
end
