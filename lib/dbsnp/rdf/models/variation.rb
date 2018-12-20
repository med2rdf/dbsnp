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
      attr_accessor :first_build

      # @return [Integer, nil] a number of the latest dbSNP Build
      attr_accessor :latest_build

      # List of items
      # - INDEL
      # - SNV
      # - INS
      # - DEL
      # - MNV
      # @return [String] a variation class
      attr_accessor :variation_class

      # @return [Hash] an array (for each alternative allele) of alternate allele frequency
      attr_accessor :frequency

      # @return [Array<String>] an array of arrays of ClinVar accessions for each alternative allele
      #   (e.g. `[["RCV000012345.6"], ["RCV000023456.7", "RCV000034567.8"]]`)
      attr_accessor :clinvar_accession # array

      def initialize
        yield self if block_given?
      end

      def to_rdf
        return @graph if @graph

        subject = ::RDF::URI.new(PREFIXES[:dbsnp] + rs.match(/\d+/)[0])
        @graph  = ::RDF::Graph.new do |g|
          g << [subject, ::RDF.type, M2R.Variation]
          g << [subject, ::RDF.type, var_class2so(variation_class)]
          g << [subject, ::RDF::Vocab::DC.identifier, rs]
          g << [subject, SNPO.is_created_in_build, first_build]
          g << [subject, SNPO.is_updated_in_build, latest_build]
          g << [subject, M2R.reference_allele, reference_allele]
          gene_id_list&.each do |id|
            g << [subject, M2R.gene, ::RDF::URI.new("#{PREFIXES[:ncbigene]}#{id}")]
          end
        end

        insert_faldo(subject)
        insert_alleles(subject)

        @graph
      end

      private

      def insert_alleles(parent_subject)
        alternative_alleles.each.with_index do |alt, i|
          allele = parent_subject / "##{alt}"
          @graph << [parent_subject, ::RDF::Vocab::DC.hasPart, allele]
          @graph << [allele, ::RDF.type, SNPO.Allele]
          @graph << [allele, M2R.alternative_allele, alt]
          @graph << [allele, ::RDF::Vocab::DC.isPartOf, parent_subject]

          if (accessions = clinvar_accession&.at(i))
            accessions.each do |accession|
              if (x = accession.match(/^RCV\d+/))
                @graph << [allele, ::RDF::RDFS.seeAlso, ::RDF::URI.new(PREFIXES[:clinvar] + x[0])]
              end
            end
          end

          frequency&.each do |k, v|
            next if v.at(i).nil?

            frequency = ::RDF::Node.new
            @graph << [allele, SIO['SIO_000216'], frequency]
            @graph << [frequency, ::RDF.type, ::RDF::Vocab::DC.Frequency]
            @graph << [frequency, ::RDF::Vocab::DC.source, k]
            @graph << [frequency, ::RDF.value, v.at(i)]
          end
        end
      end

      def insert_faldo(parent_subject)
        bn_loc = ::RDF::Node.new

        @graph << [parent_subject, FALDO.location, bn_loc]

        if reference_allele.length == 1
          @graph << [bn_loc, ::RDF.type, FALDO.Position]
          @graph << [bn_loc, ::RDF.type, FALDO.ExactPosition]
          @graph << [bn_loc, FALDO.position, position]
          if (hco = refseq2hco(chromosome, assembly))
            @graph << [bn_loc, FALDO.reference, hco]
          end
          @graph << [bn_loc, FALDO.reference, ::RDF::URI.new("#{PREFIXES[:refseq]}#{chromosome}")]
        else
          @graph << [bn_loc, ::RDF.type, FALDO.Region]
          %w[begin end].zip([position, position + (reference_allele.length - 1)]).each do |x, pos|
            bn_pos = ::RDF::Node.new
            @graph << [bn_loc, FALDO[x], bn_pos]
            @graph << [bn_pos, ::RDF.type, FALDO.Position]
            @graph << [bn_pos, ::RDF.type, FALDO.ExactPosition]
            @graph << [bn_pos, FALDO.position, pos]
            if (hco = refseq2hco(chromosome, assembly))
              @graph << [bn_pos, FALDO.reference, hco]
            end
            @graph << [bn_pos, FALDO.reference, ::RDF::URI.new("#{PREFIXES[:refseq]}#{chromosome}")]
          end
        end
      end
    end
  end
end
