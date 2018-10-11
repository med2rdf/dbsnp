require 'rexml/parsers/pullparser'
require 'zlib'

module DbSNP::RDF::Parser
  class VCFParser
    COLUMN_DELIMITER = "\t"
    INFO_DELIMITER = ';'

    RefSNP = Struct.new(:id, :variation_class, :gene_id,
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
      f = Zlib::GzipReader.new(f) if target.match?(/\.gz$/)
      new(f)
    end

    def each
      if block_given?
        @io.each_line do |line|
          refsnp = parse_line(line)
          yield refsnp if refsnp
        end
      else
        to_enum
      end
    end

    private

    def parse_line(line)
      return nil if line.start_with?('#') || line.empty?
      tokens = line.split(COLUMN_DELIMITER).map(&:strip)
      refsnp = RefSNP.new
      additional_information = parse_additional_part(tokens[7])

      refsnp.id = tokens[2]
      refsnp.variation_class = additional_information['VC']
      refsnp.gene_id = additional_information['GENEINFO'].split(':')[1] if additional_information['GENEINFO']
      refsnp.reference_allele = tokens[3]
      refsnp.alternative_alleles = tokens[4].split(',')
      refsnp.frequency = additional_information['FREQ'].split(',') if additional_information['FREQ']
      refsnp.reference_sequence = tokens[0]
      refsnp.position = tokens[1]
      refsnp.clinical_significance = additional_information['CLINSIG']
      refsnp
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