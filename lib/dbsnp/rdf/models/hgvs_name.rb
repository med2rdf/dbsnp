require 'dbsnp/rdf/models/base'

module Dbsnp
  module RDF
    module Models
      class HgvsName < Base
        belongs_to :allele
      end
    end
  end
end
