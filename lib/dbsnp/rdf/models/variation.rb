require 'active_model'
require 'active_support'
require 'active_support/inflector'

module DbSNP::RDF
  module Models
    class Variation
      include ActiveModel::Model
      include Helpers::Mappings

      # @return [String] a RefSeq accession (e.g. `"NC_000001.11"`)
      attr_accessor :chromosome

      # @return [String] a build assembly (e.g. `"GRCh38"`)
      attr_accessor :assembly

      # @return [Integer] a chromosome position
      attr_accessor :position

      # @return [Integer] a dbSNP ID (e.g. `"rs61766284"`)
      attr_accessor :rs

      # @return [Integer] a reference allele (e.g. `"C"`)
      attr_accessor :reference_allele

      # @return [Array<String>] an array of alternative allele (e.g. `["G", "T"]`)
      attr_accessor :alternative_alleles # array

      # @return [Array<Integer>] an array of NCBI gene ID (e.g. `["9636"]`)
      attr_accessor :gene_id_list # array

      # @return [Integer, nil] a number of the first dbSNP Build
      attr_accessor :build

      # List of items
      # - INDEL
      # - SNV
      # - INS
      # - DEL
      # - MNV
      # @return [String] a variation class
      attr_accessor :variation_class

      # @return [Array<String>] an array (for each alternative allele) of HGVS name
      attr_accessor :hgvs

      # List of items
      # - 0: Uncertain significance
      # - 1: not provided
      # - 2: Benign
      # - 3: Likely benign
      # - 4: Likely pathogenic
      # - 5: Pathogenic
      # - 6: drug response
      # - 8: confers sensitivity
      # - 9: risk-factor
      # - 10: association
      # - 11: protective
      # - 12: conflict
      # - 13: affects
      # - 255: other
      # @return [Array<Array<Integer>>] an array (for each alternative allele) of an array of clinical significance(s)
      attr_accessor :clinical_significance

      # @return [Hash] an array (for each alternative allele) of alternate allele frequency
      attr_accessor :frequency

      validates :chromosome, :assembly, :position, :rs,
                :reference_allele, :alternative_alleles,
                :variation_class, presence: true
      validate :multi_allele_hgvs, if: Proc.new { |x| x.hgvs.present? }
      validate :multi_allele_significance, if: Proc.new { |x| x.clinical_significance.present? }
      validate :multi_allele_frequency, if: Proc.new { |x| x.frequency.present? }

      DBSNP_BASE    = ::RDF::URI.new(PREFIXES[:dbsnp]).freeze
      GENE_BASE     = ::RDF::URI.new(PREFIXES[:ncbi_gene]).freeze
      REFSEQ_BASE   = ::RDF::URI.new(PREFIXES[:refseq]).freeze
      TAXONOMY_BASE = ::RDF::URI.new(PREFIXES[:tax]).freeze

      def initialize
        yield self if block_given?
      end

      def to_rdf
        return @graph if @graph

        validate!

        subject = ::RDF::URI.new(BASE_URI % rs)
        @graph  = ::RDF::Graph.new do |g|
          g << [subject, ::RDF.type, M2R.Variation]
          g << [subject, ::RDF.type, var_class2so(variation_class)]
          g << [subject, ::RDF::Vocab::DC.identifier, rs]
          g << [subject, ::RDF::Vocab::RDFS.seeAlso, DBSNP_BASE / rs]
          g << [subject, OBO['RO_0002162'], TAXONOMY_BASE / 9606] # TODO
          g << [subject, SNPO.build, build] if build
          gene_id_list&.each do |id|
            g << [subject, M2R.gene, GENE_BASE / id] # TODO m2r:Gene
          end
        end

        insert_faldo(subject)
        insert_alleles(subject)

        @graph
      end

      private

      def insert_alleles(parent_subject)
        alternative_alleles.each.with_index do |alt, i|
          allele = parent_subject / "#{alt}"
          @graph << [parent_subject, ::RDF::Vocab::DC.hasPart, allele]
          @graph << [allele, ::RDF.type, SNPO.Allele]

          if (x = hgvs&.at(i))
            @graph << [allele, ::RDF::Vocab::RDFS.label, x]
          end

          if (x = clinical_significance&.at(i))
            x.each do |j|
              @graph << [allele, SNPO.clinical_significance, num2significance(j)]
            end
          end

          frequency&.each do |k, v|
            next if v.at(i).nil?

            frequency = parent_subject / "#{alt}" / 'frequency' / "##{k}"
            @graph << [allele, SIO['SIO_000216'], frequency]
            source = "#{k}Frequency"
            @graph << [frequency, ::RDF.type, SNPO.respond_to?(source) ? SNPO[source] : SNPO.Frequency]
            @graph << [frequency, ::RDF.value, v.at(i)]
          end
        end
      end

      def insert_faldo(parent_subject)
        loc = parent_subject / "#{assembly}" / 'position'
        @graph << [parent_subject, FALDO.location, loc]

        if reference_allele.length == 1
          @graph << [loc, ::RDF.type, FALDO.Position]
          @graph << [loc, ::RDF.type, FALDO.ExactPosition]
          @graph << [loc, FALDO.position, position]
          if (hco = refseq2hco(chromosome))
            @graph << [loc, FALDO.reference, hco]
          end
          @graph << [loc, FALDO.reference, REFSEQ_BASE / chromosome]
        else
          @graph << [loc, ::RDF.type, FALDO.Region]
          %w[begin end].zip([position, position + (reference_allele.length - 1)]).each do |x, pos|
            node = loc / x
            @graph << [loc, FALDO[x], node]
            @graph << [node, ::RDF.type, FALDO.Position]
            @graph << [node, ::RDF.type, FALDO.ExactPosition]
            @graph << [node, FALDO.position, pos]
            if (hco = refseq2hco(chromosome))
              @graph << [node, FALDO.reference, hco]
            end
            @graph << [node, FALDO.reference, REFSEQ_BASE / chromosome]
          end
        end
      end

      def multi_allele_hgvs
        unless alternative_alleles.length == hgvs.length
          errors.add(:hgvs, "the size of HGVS names differs from alternative alleles")
        end
      end

      def multi_allele_significance
        unless alternative_alleles.length == clinical_significance.length
          errors.add(:clinical_significance, "the size of clinical significance differs from alternative alleles")
        end
      end

      def multi_allele_frequency
        frequency.each do |k, v|
          unless alternative_alleles.length == v.length
            errors.add(:frequency, "the size of #{k} frequency differs from alternative alleles")
          end
        end
      end
    end
  end
end
