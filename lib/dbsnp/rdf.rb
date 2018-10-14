require 'dbsnp/rdf/version'

module DbSNP
  module RDF
    require 'dbsnp/rdf/vocabularies'

    ROOT_DIR = File.expand_path('../../', File.dirname(__FILE__)).freeze

    BASE_URI = 'http://med2rdf.org/dbsnp/variation/%s'.freeze

    module CLI
      autoload :Runner, 'dbsnp/rdf/cli/runner'
      autoload :Convert, 'dbsnp/rdf/cli/convert'
    end

    module Helpers
      autoload :Mappings, 'dbsnp/rdf/helpers/mappings'
    end

    module Models
      autoload :Variation, 'dbsnp/rdf/models/variation'
    end

    module Reader
      autoload :VCF, 'dbsnp/rdf/reader/vcf'
    end

    module Writer
      autoload :Turtle, 'dbsnp/rdf/writer/turtle'
    end
  end
end


