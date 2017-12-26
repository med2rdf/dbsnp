require 'dbsnp/rdf/models/base'

module Dbsnp
  module RDF
    module Models
      class Allele < Base
        belongs_to :report
        has_many :frequencies
        has_many :hgvs_names
      end
    end
  end
end
