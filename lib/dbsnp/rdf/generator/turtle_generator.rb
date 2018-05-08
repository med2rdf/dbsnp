require 'parallel'
require 'benchmark'

module DbSNP::RDF
  module Generator
    class TurtleGenerator
      def initialize(src_path, dst_path, options = {})
        @writer = ::RDF::Writer.for(:turtle)

        @src = src_path

        @dst = dst_path

        @options = options
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
          main_slice   = 10000
          sub_slice    = 1000
          parsed_count = 0
          Parser::EntrySplitter.open(@src).each_slice(main_slice) do |entry_group|
            sub_entry_groups = entry_group.each_slice(sub_slice).to_a
            buffers          = Parallel.map(sub_entry_groups, in_processes: 10) do |sub_entry_group|
              statements = []
              sub_entry_group.each do |entry|
                statements += DbSNP::RDF::Converter::VariationToTriples.convert(Parser::VCFParser.parse(entry))
              end
              @writer.buffer(prefixes: DbSNP::RDF::PREFIXES) do |buffer|
                statements.each { |statement| buffer << statement }
              end.gsub(/^@.*$\n/, '')
            end

            buffers.each { |buffer| dst_file.write(buffer) }
            parsed_count += main_slice
            puts "parsed #{parsed_count} lines..."
            # puts "parsed #{i + 1} lines..." if @options[:verbose] && ((i + 1) % @options[:verbose]) == 0
          end
        end
      end
    end
  end
end