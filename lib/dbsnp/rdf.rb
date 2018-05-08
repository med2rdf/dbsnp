require "dbsnp/rdf/version"
require 'rdf'
require 'rdf/vocab'

module DbSNP
  module RDF
    ROOT_DIR = File.expand_path('../../', File.dirname(__FILE__)).freeze

    PREFIXES = {
        snpo:      'http://purl.jp/bio/10/dbsnp/',
        m2r:       'http://med2rdf.org/ontology/med2rdf#',
        dbsnp:     'http://identifiers.org/dbsnp/',
        ncbi_gene: 'http://identifiers.org/ncbigene/',
        refseq:    'http://identifiers.org/refseq/',
        tax:       'http://identifiers.org/taxonomy/',
        obo:       'http://purl.obolibrary.org/obo/',
        faldo:     'http://biohackathon.org/resource/faldo#',
        rdf:       ::RDF::RDFV.to_s,
        dc:        ::RDF::Vocab::DC.to_s,
        xsd:       ::RDF::XSD.to_s,
    }.freeze

    module CLI
      autoload :Runner, 'dbsnp/rdf/cli/runner'
      autoload :Convert, 'dbsnp/rdf/cli/convert'
    end

    module Converter
      autoload :VariationToTriples, 'dbsnp/rdf/converter/variation_to_triples'
    end

    module Parser
      autoload :VCFParser, 'dbsnp/rdf/parser/vcf_parser'
      autoload :EntrySplitter, 'dbsnp/rdf/parser/entry_splitter'
    end

    module Vocabularies
      autoload :M2r, 'dbsnp/rdf/vocabularies'
      autoload :Obo, 'dbsnp/rdf/vocabularies'
      autoload :DbSNP, 'dbsnp/rdf/vocabularies'
    end

    module Generator
      autoload :TurtleGenerator, 'dbsnp/rdf/generator/turtle_generator'
    end

    module Util
      autoload :MultiBlockGzipReader, 'dbsnp/rdf/util/multi_block_gzip_reader'
    end
  end
end
