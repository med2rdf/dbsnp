require 'rexml/parsers/pullparser'
require 'zlib'

module DbSNP::RDF::Parser
  class VCFParser
    include Enumerable

    COLUMN_DELIMITER = "\t".freeze
    INFO_DELIMITER   = ';'.freeze
    MISSING_VALUE    = '.'.freeze

    Variation = Struct.new(:rs_id, :variation_class, :gene_id,
                           :reference_allele, :alternative_alleles,
                           :frequency, :reference_sequence, :position, :clinical_significance)

    class FormatError < StandardError
      def initialize(line)
        super("Invalid Format: #{line}")
      end
    end

    def initialize(io)
      @io = io.is_a?(String) ? StringIO.new(io) : io
    end


    def self.open(target)
      f = File.open(target)
      f = Zlib::GzipReader.new(f) if target.match?(/(\.bgz)|(\.gz)$/)
      new(f)
    end

    def each
      if block_given?
        @io.each_line do |line|
          variation = parse_line(line)
          yield variation if variation
        end
      else
        to_enum
      end
    end

    private

    def parse_line(line)
      return nil if line.start_with?('#') || line.empty?
      tokens                 = line.split(COLUMN_DELIMITER).map(&:strip)
      variation              = Variation.new
      additional_information = parse_additional_part(tokens[7])

      variation.rs_id                 = tokens[2]
      variation.variation_class       = additional_information['VC']
      variation.gene_id               = additional_information['GENEINFO'].split(':')[1] if additional_information['GENEINFO']
      variation.reference_allele      = tokens[3]
      variation.alternative_alleles   = tokens[4].split(',')
      variation.frequency             = parse_frequency(additional_information['FREQ']) if additional_information['FREQ']
      variation.reference_sequence    = tokens[0]
      variation.position              = tokens[1]
      variation.clinical_significance = parse_clinical_significance(additional_information['CLNSIG']) if additional_information['CLNSIG']
      variation
    end

    def parse_clinical_significance(text)
      text.split(',').map{ |sig| sig == MISSING_VALUE ? nil : sig }
    end

    def parse_frequency(text)
      from_1000g = text.split('|').select { |t| t.start_with?('1000Genomes') }
      raise new InvalidFormat(text) if from_1000g.size > 1
      return nil if from_1000g.empty?
      from_1000g[0].split(':')[1].split(',').map{ |freq| freq == MISSING_VALUE ? nil : freq }
    end

    def parse_additional_part(text)
      tokens = text.split(INFO_DELIMITER)
      tokens.map do |token|
        k, v = token.split('=')
        if k.nil? || v.nil?
          nil
        else
          [k, v]
        end
      end.compact.to_h
    end

  end
end