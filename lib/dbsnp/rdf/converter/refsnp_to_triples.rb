require 'rdf'

module DbSNP::RDF
  module Converter

    HGVS_PATTERN = /^(.+):.\.(\d+)([[:alpha:]>]+)$/

    class ValidationError < StandardError
      def initialize(refsnp)
        super("invalid refsnp: #{refsnp}")
      end
    end

    CLASS_OBO_MAP = {
        'SNV'                          => Vocabularies::Obo.SO_0001483,
        'INDEL'                        => Vocabularies::Obo.SO_1000032,
        'INS'                          => Vocabularies::Obo.SO_0000667,
        'DEL'                          => Vocabularies::Obo.SO_0000159,
        'MNV'                          => Vocabularies::Obo.SO_0002007,
    }

    class RefsnpToTriples
      class << self
        def convert(refsnp)
          statements = []

          raise ValidationError.new(refsnp) unless validate(refsnp)

          subject = RDF::URI.new("#{PREFIXES[:dbsnp]}#{refsnp.id}")
          if refsnp.alternative_alleles.count == 1
            statements += part_statements(subject, refsnp, refsnp.alternative_alleles[0], 0)
          else
            statements << RDF::Statement.new(subject,
                                             RDF::Vocab::DC::identifier,
                                             refsnp.id)

            statements << RDF::Statement.new(subject,
                                             ::RDF::type,
                                             Vocabularies::M2r.Variation)


            refsnp.alternative_alleles.each_with_index do |alt, i|
              part_subject = RDF::URI.new("#{subject}##{refsnp.reference_allele}-#{alt}")
              statements << RDF::Statement.new(subject,
                                               ::RDF::Vocab::DC::hasPart,
                                               part_subject)
              statements += part_statements(part_subject, refsnp, alt, i)
            end
          end

          statements
        end

        def part_statements(subject, refsnp, alt, idx)
          statements = []

          statements << RDF::Statement.new(subject,
                                           RDF::Vocab::DC::identifier,
                                           refsnp.id)

          statements << RDF::Statement.new(subject,
                                           ::RDF::type,
                                           Vocabularies::M2r.Variation)

          unless CLASS_OBO_MAP[refsnp.variation_class].nil?
            statements << RDF::Statement.new(subject,
                                             ::RDF::type,
                                             CLASS_OBO_MAP[refsnp.variation_class])
          end

          statements << RDF::Statement.new(subject,
                                           Vocabularies::DbSNP.taxonomy,
                                           RDF::URI.new(PREFIXES[:tax] + '9606'))

          if refsnp.gene_id
            statements << RDF::Statement.new(subject,
                                             Vocabularies::M2r.gene,
                                             RDF::URI.new(PREFIXES[:ncbi_gene] + refsnp.gene_id))
          end

          statements << RDF::Statement.new(subject,
                                           Vocabularies::M2r.reference_allele,
                                           refsnp.reference_allele)

          statements << RDF::Statement.new(subject,
                                           Vocabularies::M2r.alternative_allele,
                                           alt)

          if refsnp.frequency
            statements << RDF::Statement.new(subject,
                                             Vocabularies::Snpo.frequency,
                                             refsnp.frequency[idx + 1].to_f)
          end

          statements << RDF::Statement.new(subject,
                                           Vocabularies::Snpo.hgvs,
                                           "#{refsnp.reference_sequence}:g.#{hgvs_change(refsnp, alt)}")

          location_node = RDF::Node.new
          statements << RDF::Statement.new(subject,
                                           Vocabularies::Faldo.location,
                                           location_node)

          statements << RDF::Statement.new(location_node,
                                           Vocabularies::Faldo.position,
                                           refsnp.position.to_i)

          statements << RDF::Statement.new(location_node,
                                           RDF::type,
                                           Vocabularies::Faldo.ExactPosition)

          statements << RDF::Statement.new(location_node,
                                           Vocabularies::Faldo.reference,
                                           RDF::URI.new(PREFIXES[:refseq] + refsnp.reference_sequence))
          statements
        end

        def hgvs_change(refsnp, alt)
          ref = refsnp.reference_allele
          if ref.length == 1 && alt.length == 1
            "#{refsnp.position}#{ref}>#{alt}"
          elsif ref.length > alt.length && ref.start_with?(alt)
            start_pos = refsnp.position.to_i + alt.length
            end_pos   = refsnp.position.to_i + ref.length
            if end_pos - start_pos == 1
              "#{start_pos}del#{ref[-1]}"
            else
              "#{start_pos}_#{end_pos}del#{ref[alt.length..-1]}"
            end
          elsif ref.length < alt.length && alt.start_with?(ref)
            if repeated_in?(ref, alt)
              start_pos = refsnp.position.to_i
              end_pos   = refsnp.position.to_i + ref.length
              if end_pos - start_pos == 1
                "#{start_pos}dup#{ref[-1]}"
              else
                "#{start_pos}_#{end_pos}dup#{ref[-1]}"
              end
            else
              start_pos = refsnp.position.to_i + ref.length
              end_pos   = start_pos + 1
              "#{start_pos}_#{end_pos}ins#{ref[ref.length..-1]}"
            end
          else
            start_pos = refsnp.position.to_i
            end_pos   = start_pos + ref.length
            "#{start_pos}_#{end_pos}delins#{alt}"
          end
        end

        def common_prefix(str_a, str_b)
          idx = 0
          while idx < str_a.length && idx < str_b.length && str_a[idx] == str_b[idx]
            idx += 1
          end
          str_a.length < str_b.length ? str_a[0..idx] : str_b[0..idx]
        end

        def repeated_in?(substr, superstr)
          idx = 0
          while idx < superstr.length
            return false if substr != superstr[idx, substr.length]
            idx += substr.length
          end
          true
        end

        def validate(refsnp)
          CLASS_OBO_MAP.key?(refsnp.variation_class)
        end
      end
    end
  end
end