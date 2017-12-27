require 'dbsnp/rdf/models/base'

module Dbsnp
  module RDF
    module Models
      class Significance < Base
        belongs_to :report
      end
    end
  end
end
