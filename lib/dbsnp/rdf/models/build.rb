require 'dbsnp/rdf/models/base'

module Dbsnp
  module RDF
    module Models
      class Build < Base
        belongs_to :report
      end
    end
  end
end
