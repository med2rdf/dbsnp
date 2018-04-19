module Dbsnp::Rdf::Parser
  class XmlParser

    Refsnp = Struct.new(:id, :hgsv)

    class FormatError < StandardError
      def initialize(line)
        super("Invalid Format: #{line}")
      end
    end

    def self.open(path)
      f = File.open(path)
      f = Zlib::GzipReader.new(f) if args[0].match?(/\.gz$/)
      new(f)
    end

    def initialize(io)
      @xml_parser = REXML.Parsers::PullParser.new(io)
    end

    def get_next
      in_hgvs    = false
      current_rs = nil
      while @xml_parser.has_next?
        event = parser.pull

        if event.start_element?
          case event[0]
          when 'hgvs'
            in_hgvs = true
          when 'Rs'
            current_rs = Refsnp.new(event[1]['rsId'], [])
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
          else
            # do nothing
          end
        end

        if in_hgvs && event.text?
          current_rs.hgsv << event[0]
        end
      end
      nil
    end

  end
end