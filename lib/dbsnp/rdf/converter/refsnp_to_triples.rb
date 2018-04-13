require 'rdf'

module Dbsnp::Rdf
  module Converter
    class ValidationError < StandardError
      def initialize(refsnp)
        super("invalid refsnp: #{refsnp}")
      end
    end

    CLASS_OBO_MAP = {
        'snp' => Vocabularies::Obo.SO_0001483,
    }

    class RefsnpToTriples
      class << self
        def convert(refsnp)
          statements = []

          raise ValidationError.new(refsnp) unless validate(refsnp)
          rs = refsnp.rs[0]

          subject = RDF::URI.new("#{PREFIXES[:dbsnp]}#{rs.rs_id}")
          subject_part = RDF::URI.new("#{PREFIXES[:dbsnp]}#{rs.rs_id}##{refsnp.snp[0].alleles.gsub(/\//, '-')}")

          statements << RDF::Statement.new(subject,
                                           RDF::Vocab::DC::identifier,
                                           rs.rs_id)

          statements << RDF::Statement.new(subject,
                                           ::RDF::type,
                                           Vocabularies::M2r.Variation)

          statements << RDF::Statement.new(subject,
                                           ::RDF::Vocab::DC::hasPart,
                                           subject_part)


          statements << RDF::Statement.new(subject_part,
                                           ::RDF::type,
                                           Vocabularies::M2r.Variation)

          statements << RDF::Statement.new(subject_part,
                                           ::RDF::type,
                                           CLASS_OBO_MAP[rs.snp_class])

          statements << RDF::Statement.new(subject_part,
                                           RDF::Vocab::DC::identifier,
                                           rs.rs_id)

          statements << RDF::Statement.new(subject_part,
                                           Vocabularies.dbsnp.taxonomy,
                                           RDF::URI.new(PREFIXES[:tax] + rs.taxonomy_id))

          statements << RDF::Statement.new(subject_part,
                                           Vocabularies.M2r.gene,
                                           RDF::URI.new(PREFIXES[:ncbi_gene] + rs.taxonomy_id))

          statements

        end

        def validate(refsnp)
          refsnp.rs.size == 1 && refsnp.snp.size == 1 && refsnp.ctg.size == 1
        end
      end
    end
  end
end