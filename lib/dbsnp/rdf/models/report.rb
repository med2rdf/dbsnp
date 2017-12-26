require 'dbsnp/rdf/models/base'

module Dbsnp
  module RDF
    module Models
      class Report < Base
        has_many :alleles
        has_many :hgvs_names
        has_many :builds

        validates :snp_class,
                  inclusion: { in: %w[snp in-del heterozygous microsatellite
                                      named-locus no-variation mixed
                                      multinucleotide-polymorphism] }
        validates :snp_type,
                  inclusion: { in: %w[notwithdrawn artifact gene-duplication
                                      duplicate-submission notspecified
                                      ambiguous-location low-map-quality] }
        validates :mol_type,
                  inclusion: { in: %w[genomic cDNA mito chloro unknown] }
      end
    end
  end
end
