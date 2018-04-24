require 'rdf'

module Dbsnp::Rdf
  module Converter

    HGVS_PATTERN = /^(.+):.\.(\d+)([[:alpha:]>]+)$/

    class ValidationError < StandardError
      def initialize(refsnp)
        super("invalid refsnp: #{refsnp}")
      end
    end

    CLASS_OBO_MAP = {
        'snp'                          => Vocabularies::Obo.SO_0001483,
        'in-del'                       => Vocabularies::Obo.SO_1000032,
        'heterozygous'                 => nil,
        'microsatellite'               => Vocabularies::Obo.SO_0000289,
        'named-locus'                  => Vocabularies::Obo.SO_1000032,
        'no-variation'                 => nil,
        'mixed'                        => nil,
        'multinucleotide-polymorphism' => Vocabularies::Obo.SO_0002007
    }

    class RefsnpToTriples
      class << self
        def convert(refsnp)
          statements = []

          raise ValidationError.new(refsnp) unless validate(refsnp)

          rs_id = 'rs' + refsnp.id

          subject = RDF::URI.new("#{PREFIXES[:dbsnp]}#{rs_id}")

          statements << RDF::Statement.new(subject,
                                           RDF::Vocab::DC::identifier,
                                           rs_id)

          statements << RDF::Statement.new(subject,
                                           ::RDF::type,
                                           Vocabularies::M2r.Variation)

          refsnp_hash(refsnp).each do |part, hgvs_list|

            statements << RDF::Statement.new(subject,
                                             ::RDF::Vocab::DC::hasPart,
                                             part)

            statements << RDF::Statement.new(part,
                                             ::RDF::type,
                                             Vocabularies::M2r.Variation)

            unless CLASS_OBO_MAP[refsnp.snp_type].nil?
              statements << RDF::Statement.new(part,
                                               ::RDF::type,
                                               CLASS_OBO_MAP[refsnp.snp_type])
            end

            statements << RDF::Statement.new(part,
                                             RDF::Vocab::DC::identifier,
                                             rs_id)

            statements << RDF::Statement.new(part,
                                             Vocabularies::Dbsnp.taxonomy,
                                             RDF::URI.new(PREFIXES[:tax] + '9606'))

            if refsnp.gene_id
              statements << RDF::Statement.new(part,
                                               Vocabularies::M2r.gene,
                                               RDF::URI.new(PREFIXES[:ncbi_gene] + refsnp.gene_id))
            end

            statements << RDF::Statement.new(part,
                                             Vocabularies::M2r.reference_allele,
                                             ref_allele(hgvs_list[0]))

            statements << RDF::Statement.new(part,
                                             Vocabularies::M2r.alternative_allele,
                                             alt_allele(hgvs_list[0]))

            statements << RDF::Statement.new(part,
                                             Vocabularies::Snpo.frequency,
                                             refsnp.frequency.to_f)

            statements << RDF::Statement.new(part,
                                             Vocabularies::Snpo.sample_size,
                                             refsnp.sample_size.to_i)

            hgvs_list.each do |hgvs|
              statements << RDF::Statement.new(part,
                                               Vocabularies::Snpo.hgvs,
                                               hgvs)

              location_node = RDF::Node.new
              statements << RDF::Statement.new(part,
                                               Vocabularies::Faldo.location,
                                               location_node)

              statements << RDF::Statement.new(location_node,
                                               Vocabularies::Faldo.position,
                                               hgvs_position(hgvs))

              statements << RDF::Statement.new(location_node,
                                               RDF::type,
                                               Vocabularies::Faldo.ExactPosition)

              statements << RDF::Statement.new(location_node,
                                               Vocabularies::Faldo.reference,
                                               RDF::URI.new(PREFIXES[:refseq] + hgvs_refseq(hgvs)))
            end
          end

          statements

        end

        def refsnp_hash(refsnp)
          hgvs_chromosome(refsnp).group_by do |nc|
            RDF::URI.new("#{PREFIXES[:dbsnp]}rs#{refsnp.id}##{hgvs_change(nc).gsub(/>/, '-')}")
          end
        end

        def ref_allele(hgvs)
          change = hgvs_change(hgvs)
          if change.include?('del')
            change.match(/del(.+)/)[1]
          else
            change.match(/(.+)>(.+)/)[1]
          end
        end

        def alt_allele(hgvs)
          change = hgvs_change(hgvs)
          if change.include?('del')
            '-'
          else
            change.match(/(.+)>(.+)/)[2]
          end
        end

        def hgvs_chromosome(refsnp)
          refsnp.hgvs.select { |hgvs| hgvs.start_with?('NC_') }
        end

        def hgvs_change(hgvs)
          hgvs.match(HGVS_PATTERN)[3]
        end

        def hgvs_position(hgvs)
          hgvs.match(HGVS_PATTERN)[2].to_i
        end

        def hgvs_refseq(hgvs)
          hgvs.match(HGVS_PATTERN)[1]
        end

        def validate(refsnp)
          CLASS_OBO_MAP.key?(refsnp.snp_type)
        end
      end
    end
  end
end