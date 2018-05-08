require 'parallel'
require 'benchmark'
require 'rdf/turtle'
require 'rdf/raptor'

module DbSNP::RDF
  module Generator
    class TurtleGenerator
      def initialize(src_path, dst_path, options = {})
        @src = src_path

        @dst = dst_path

        @options = options

        if @options[:raptor]
          @writer = RDF::Raptor::Turtle::Writer
        else
          @writer = RDF::Turtle::Writer
        end
      end

      def all
        ontology
        refsnps
      end

      def ontology
        File.open(File.join(@dst, 'dbsnp.ttl'), 'w') do |dst_file|
          dst_file.write(@writer.buffer(prefixes: Vocabularies::DbSNP.prefixes, stream: true) do |buffer|
            # just output header
          end)
          dst_file.write((Vocabularies::DbSNP.to_ttl).gsub(/^@.*$\n/, ''))
        end
      end

      def refsnps
        File.open(File.join(@dst, 'refsnps.ttl'), 'w') do |dst_file|
          dst_file.write(@writer.buffer(prefixes: DbSNP::RDF::PREFIXES, stream: true) do |buffer|
            # just output header
          end)
          dst_file.flush
          slice_size   = @options[:slice] || 10000
          entry_count = 0
          time_sum = 0
          Parser::EntrySplitter.open(@src).each_slice(slice_size) do |entries|
            time = Benchmark.realtime{ serialize_parallel(entries).each { |ttl_text| dst_file.write(ttl_text) } }
            entry_count += entries.size
            time_sum += time
            puts "#{entry_count} entries were processed... (this block: #{time} sec, sum: #{time_sum} sec)"
          end
        end
      end

      def serialize_parallel(entries)
        process_count = @options[:process] || 4
        if process_count == 1
          [serialize(entries)]
        else
          sub_slice = entries.length / process_count
          Parallel.map(entries.each_slice(sub_slice).to_a, in_processes: process_count) do |sub_entry_group|
            serialize(sub_entry_group)
          end
        end
      end

      def serialize(entries)
        statements = entries.map { |entry| DbSNP::RDF::Converter::VariationToTriples.convert(Parser::VCFParser.parse(entry)) }.flatten
        @writer.buffer(prefixes: DbSNP::RDF::PREFIXES) do |writer|
          statements.each { |statement| writer << statement }
        end.gsub(/^@.*$\n/, '')
      end
    end
  end
end
