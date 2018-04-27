require 'rdf'

module DbSNP::RDF
  module Converter

    HGVS_PATTERN = /^(.+):.\.(\d+)([[:alpha:]>]+)$/

    class ValidationError < StandardError
      def initialize(variant_call)
        super("invalid variation: #{variation}")
      end
    end

    CLASS_OBO_MAP = {
        'SNV'   => Vocabularies::Obo.SO_0001483,
        'INDEL' => Vocabularies::Obo.SO_1000032,
        'INS'   => Vocabularies::Obo.SO_0000667,
        'DEL'   => Vocabularies::Obo.SO_0000159,
        'MNV'   => Vocabularies::Obo.SO_0002007,
    }.freeze

    CLINICAL_SIGNIFICANCE_MAP = {
        '0'   => 'Uncertain significance',
        '1'   => 'Not provided',
        '2'   => 'Benign',
        '3'   => 'Likely benign',
        '4'   => 'Likely pathogenic',
        '5'   => 'Pathogenic',
        '6'   => 'Drug response',
        '8'   => 'Confers sensitivity',
        '9'   => 'Risk-factor',
        '10'  => 'Association',
        '11'  => 'Protective',
        '12'  => 'Conflict',
        '13'  => 'Affects',
        '255' => 'Other',
    }.freeze

    class VariationToTriples
      class << self
        def convert(variation)
          statements = []

          raise ValidationError.new(variation) unless validate(variation)

          subject = RDF::URI.new("#{PREFIXES[:dbsnp]}#{variation.rs_id}")
          if variation.alternative_alleles.count == 1
            statements += part_statements(subject, variation, variation.alternative_alleles[0], 0)
          else
            statements << RDF::Statement.new(subject,
                                             RDF::Vocab::DC::identifier,
                                             variation.rs_id)

            statements << RDF::Statement.new(subject,
                                             ::RDF::type,
                                             Vocabularies::M2r.Variation)


            variation.alternative_alleles.each_with_index do |alt, i|
              part_subject = RDF::URI.new("#{subject}##{variation.reference_allele}-#{alt}")
              statements << RDF::Statement.new(subject,
                                               ::RDF::Vocab::DC::hasPart,
                                               part_subject)
              statements += part_statements(part_subject, variation, alt, i)
            end
          end

          statements
        end

        def part_statements(subject, variation, alt, idx)
          statements = []

          statements << RDF::Statement.new(subject,
                                           RDF::Vocab::DC::identifier,
                                           variation.rs_id)

          statements << RDF::Statement.new(subject,
                                           ::RDF::type,
                                           Vocabularies::M2r.Variation)

          unless CLASS_OBO_MAP[variation.variation_class].nil?
            statements << RDF::Statement.new(subject,
                                             ::RDF::type,
                                             CLASS_OBO_MAP[variation.variation_class])
          end

          statements << RDF::Statement.new(subject,
                                           Vocabularies::DbSNP.taxonomy,
                                           RDF::URI.new(PREFIXES[:tax] + '9606'))

          variation.gene_id_list.each do |gene_id|
            statements << RDF::Statement.new(subject,
                                             Vocabularies::M2r.gene,
                                             RDF::URI.new(PREFIXES[:ncbi_gene] + gene_id))
          end

          statements << RDF::Statement.new(subject,
                                           Vocabularies::M2r.reference_allele,
                                           variation.reference_allele)

          statements << RDF::Statement.new(subject,
                                           Vocabularies::M2r.alternative_allele,
                                           alt)

          if variation.frequency && variation.frequency[idx + 1]
            statements << RDF::Statement.new(subject,
                                             Vocabularies::Snpo.frequency,
                                             variation.frequency[idx + 1].to_f)
          end


          if variation.clinical_significance && CLINICAL_SIGNIFICANCE_MAP[variation.clinical_significance[idx + 1]]
            statements << RDF::Statement.new(subject,
                                             Vocabularies::Snpo.clinical_significance,
                                             CLINICAL_SIGNIFICANCE_MAP[variation.clinical_significance[idx + 1]])
          end


          if variation.hgvs && variation.hgvs[idx + 1]
            # use hgvs in VCF
            statements << RDF::Statement.new(subject,
                                             Vocabularies::Snpo.hgvs,
                                             variation.hgvs[idx + 1])
          else
            # construct hgvs
            statements << RDF::Statement.new(subject,
                                             Vocabularies::Snpo.hgvs,
                                             "#{variation.reference_sequence}:g.#{hgvs_change(variation, alt)}")
          end


          location_node = RDF::Node.new
          statements << RDF::Statement.new(subject,
                                           Vocabularies::Faldo.location,
                                           location_node)


          reference_uri = RDF::URI.new(PREFIXES[:refseq] + variation.reference_sequence)
          if variation.reference_allele.length == 1
            statements << RDF::Statement.new(location_node,
                                             Vocabularies::Faldo.position,
                                             variation.position.to_i)

            statements << RDF::Statement.new(location_node,
                                             RDF::type,
                                             Vocabularies::Faldo.ExactPosition)

            statements << RDF::Statement.new(location_node,
                                             Vocabularies::Faldo.reference,
                                             reference_uri)
          else
            statements << RDF::Statement.new(location_node,
                                             RDF::type,
                                             Vocabularies::Faldo.Region)

            begin_node = RDF::Node.new


            statements << RDF::Statement.new(location_node,
                                             Vocabularies::Faldo.begin,
                                             begin_node)

            statements << RDF::Statement.new(begin_node,
                                             RDF::type,
                                             Vocabularies::Faldo.ExactPosition)

            statements << RDF::Statement.new(begin_node,
                                             Vocabularies::Faldo.position,
                                             variation.position.to_i)

            statements << RDF::Statement.new(begin_node,
                                             Vocabularies::Faldo.reference,
                                             reference_uri)


            end_node = RDF::Node.new


            statements << RDF::Statement.new(location_node,
                                             Vocabularies::Faldo.end,
                                             end_node)

            statements << RDF::Statement.new(end_node,
                                             RDF::type,
                                             Vocabularies::Faldo.ExactPosition)

            statements << RDF::Statement.new(end_node,
                                             Vocabularies::Faldo.position,
                                             variation.position.to_i + variation.reference_allele.length - 1)

            statements << RDF::Statement.new(end_node,
                                             Vocabularies::Faldo.reference,
                                             reference_uri)
          end

          statements
        end

        def hgvs_change(variation, alt)
          ref = variation.reference_allele
          if ref.length == 1 && alt.length == 1
            "#{variation.position}#{ref}>#{alt}"
          elsif ref.length > alt.length && ref.start_with?(alt)
            start_pos = variation.position.to_i + alt.length
            end_pos   = variation.position.to_i + ref.length - 1
            if end_pos == start_pos
              "#{start_pos}del#{ref[-1]}"
            else
              "#{start_pos}_#{end_pos}del#{ref[alt.length..-1]}"
            end
          elsif ref.length < alt.length && alt.start_with?(ref)
            if repeated_in?(ref, alt)
              start_pos = variation.position.to_i
              end_pos   = variation.position.to_i + ref.length - 1
              if end_pos == start_pos
                "#{start_pos}dup#{ref[-1]}"
              else
                "#{start_pos}_#{end_pos}dup#{ref[-1]}"
              end
            else
              start_pos = variation.position.to_i + ref.length - 1
              end_pos   = start_pos + 1
              "#{start_pos}_#{end_pos}ins#{alt[ref.length..-1]}"
            end
          else
            start_pos = variation.position.to_i
            end_pos   = start_pos + ref.length - 1
            "#{start_pos}_#{end_pos}del#{ref}ins#{alt}"
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

        def validate(variation)
          CLASS_OBO_MAP.key?(variation.variation_class)
        end
      end
    end
  end
end