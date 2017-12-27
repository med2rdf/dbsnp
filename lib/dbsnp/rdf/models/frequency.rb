require 'dbsnp/rdf/models/base'

module Dbsnp
  module RDF
    module Models
      class Frequency < Base
        belongs_to :report
      end
    end
  end
end
