require 'rdf'
require 'rdf/raptor'
require 'rdf/turtle'
require 'zlib'

module DbSNP::RDF
  module Writer
    class Turtle
      class << self
        def open(path, compress: true)
          f = if compress
                Zlib::GzipWriter.open(path)
              else
                File.open(path, 'w')
              end

          writer = new(f)

          return writer unless block_given?

          begin
            yield writer
          ensure
            if f && !f.closed?
              f.close
            end
          end
        end
      end

      def initialize(io = STDOUT)
        @io = io

        yield self if block_given?
      end

      OPTIONS = { base_uri: BASE_URI % '',
                  prefixes: PREFIXES }

      # @param  [RDF::Enumerable, RDF::Statement, #to_rdf] data
      # @return [Integer] the number of bytes written
      def <<(data)
        buffer = ::RDF::Writer.for(:turtle).buffer(OPTIONS) do |writer|
          writer << data
        end

        buffer.gsub!(/^@.*\n/, '')

        unless @header_written
          ::RDF::Turtle::Writer.new(@io, OPTIONS.merge(stream: true)).write_epilogue
          @header_written = true
        end

        @io.write buffer
      end
    end
  end
end
