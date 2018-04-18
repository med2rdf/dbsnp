module Dbsnp::Rdf::Parser
  class VcfParser

    Refsnp = Struct.new(:id, :ref, :alt)

    class FormatError < StandardError
      def initialize(line)
        super("Invalid Format: #{line}")
      end
    end

    def self.parse_line(text)
      return nil if text.start_with?('#') || text.empty?
      tokens = text.split("\t")
      raise FormatError.new(text) unless tokens.size == 8
      Refsnp.new(tokens[2], tokens[3], tokens[4])
    end
  end
end