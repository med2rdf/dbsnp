require 'rexml/parsers/pullparser'

module DbSNP::RDF::Parser
  class XmlParser
    include Enumerable

    Refsnp = Struct.new(:id, :snp_type, :gene_id, :frequency,
                        :sample_size, :clinical_significance, :hgvs)

    class FormatError < StandardError
      def initialize(line)
        super("Invalid Format: #{line}")
      end
    end

    def self.open(path)
      f = File.open(path)
      f = Zlib::GzipReader.new(f) if path.match?(/\.gz$/)
      new(f)
    end

    def initialize(io)
      io = io.is_a?(String) ? StringIO.new(io) : io
      @xml_parser = REXML::Parsers::PullParser.new(io)
    end

    def each
      if block_given?
        while (entry = get_next)
          yield entry
        end
      else
        to_enum
      end
    end

    def get_next
      in_hgvs    = false
      in_clinical = false
      current_rs = nil
      while @xml_parser.has_next?
        event = @xml_parser.pull

        if event.start_element?
          case event[0]
          when 'hgvs'
            in_hgvs = true
          when 'Rs'
            current_rs = Refsnp.new
            current_rs.id = event[1]['rsId']
            current_rs.snp_type = event[1]['snpClass']
            current_rs.hgvs = []
          when 'Frequency'
            current_rs.frequency = event[1]['freq']
            current_rs.sample_size = event[1]['sampleSize']
          when 'FxnSet'
            current_rs.gene_id = event[1]['geneId']
          when 'ClinicalSignificance'
            in_clinical = true
          else
            # do nothing
          end
        end

        if event.end_element?
          case event[0]
          when 'hgvs'
            in_hgvs = false
          when 'Rs'
            return current_rs
          when 'ClinicalSignificance'
            in_clinical = false
          else
            # do nothing
          end
        end

        if event.text?
          if in_hgvs
            current_rs.hgvs << event[1]
          end

          if in_clinical
            current_rs.clinical_significance = event[1]
          end
        end
      end
      nil
    end

  end
end