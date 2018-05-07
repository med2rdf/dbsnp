require 'rexml/parsers/pullparser'

module DbSNP::RDF::Parser
  class VCFParser
    include Enumerable

    COLUMN_DELIMITER = "\t".freeze
    INFO_DELIMITER   = ';'.freeze
    MISSING_VALUE    = '.'.freeze

    Variation = Struct.new(:rs_id, :variation_class, :gene_id_list,
                           :reference_allele, :alternative_alleles,
                           :frequency, :reference_sequence, :position, :clinical_significance, :hgvs)

    class FormatError < StandardError
      def initialize(line)
        super("Invalid Format: #{line}")
      end
    end

    def initialize(io)
      @file_path = io.is_a?(File) ? io.path : 'StringIO'
      @io = io.is_a?(String) ? StringIO.new(io) : io
    end


    def self.open(target)
      f = File.open(target)
      f = DbSNP::RDF::Util::MultiBlockGzipReader.new(f) if target.match?(/(\.bgz)|(\.gz)$/)
      new(f)
    end

    def each
      if block_given?
        lineno = 0 #TODO delegate lineno to @io
        @io.each_line do |line|
          lineno += 1
          variation = parse_line(line, lineno)
          yield variation if variation
        end
      else
        to_enum
      end
    end

    private

    def parse_line(line, lineno)
      retrial = false
      begin
        return nil if line.start_with?('#') || line.empty?
        tokens                 = line.split(COLUMN_DELIMITER).map(&:strip)
        variation              = Variation.new
        additional_information = parse_additional_part(tokens[7])

        variation.rs_id                 = tokens[2]
        variation.variation_class       = additional_information['VC']
        if additional_information['GENEINFO']
          variation.gene_id_list          = additional_information['GENEINFO'].split('|').map{ |pair| pair.split(':')[1]}
        else
          variation.gene_id_list        = []
        end
        variation.reference_allele      = tokens[3]
        variation.alternative_alleles   = tokens[4].split(',')
        variation.frequency             = parse_frequency(additional_information['FREQ']) if additional_information['FREQ']
        variation.reference_sequence    = tokens[0]
        variation.position              = tokens[1]
        variation.clinical_significance = parse_comma_separated_entries(additional_information['CLNSIG']) if additional_information['CLNSIG']
        variation.hgvs                  = parse_comma_separated_entries(additional_information['CLNHGVS']) if additional_information['CLNHGVS']
        variation
      rescue ArgumentError => ae
        raise ae if retrial

        warn(["Warning: #{ae.message}, #{@file_path}:#{lineno}", line].join("\n"))
        line    = line.scrub('?')
        retrial = true
        retry
      end
    end

    def parse_comma_separated_entries(text)
      text.split(',').map { |val| val == MISSING_VALUE ? nil : val }
    end

    def parse_frequency(text)
      from_1000g = text.split('|').select { |t| t.start_with?('1000Genomes') }
      raise new InvalidFormat(text) if from_1000g.size > 1
      return nil if from_1000g.empty?
      from_1000g[0].split(':')[1].split(',').map { |freq| freq == MISSING_VALUE ? nil : freq }
    end

    def parse_additional_part(text)
      tokens = text.split(INFO_DELIMITER)
      tokens.map do |token|
        idx = token.index('=')
        if idx.nil? || idx == token.length - 1
          nil
        else
          k = token[0...idx]
          v = token[(idx + 1)..-1]
          [k, v]
        end
      end.compact.to_h
    end

  end
end