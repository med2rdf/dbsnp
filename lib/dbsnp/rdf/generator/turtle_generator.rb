module DbSNP::RDF
  module Generator
    class TurtleGenerator
      def initialize(src_path, dst_path)
        @writer = ::RDF::Writer.for(:turtle)

        @src = src_path

        @dst = dst_path
      end

      def all
        ontology
        refsnps
      end

      def ontology
        # TODO use prefixes different from #refsnps
        File.open(File.join(@dst, 'dbsnp.ttl'), 'w') do |dst_file|
          dst_file.write(@writer.buffer(prefixes: DbSNP::RDF::PREFIXES, stream: true) do |buffer|
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
          Parser::VCFParser.open(@src).each do |refsnp|
            dst_file.write(@writer.buffer(prefixes: DbSNP::RDF::PREFIXES) do |buffer|
              DbSNP::RDF::Converter::VariationToTriples.convert(refsnp).each { |statement| buffer << statement }
            end.gsub(/^@.*$\n/, ''))
          end
        end
      end
    end
  end
end