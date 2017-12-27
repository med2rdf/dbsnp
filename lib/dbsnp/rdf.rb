require 'dbsnp/rdf/version'

module Dbsnp
  module RDF
    module CLI
      autoload :Convert, 'dbsnp/rdf/cli/convert'
      autoload :Runner, 'dbsnp/rdf/cli/runner'
    end

    module Models
      autoload :Allele, 'dbsnp/rdf/models/allele'
      autoload :Base, 'dbsnp/rdf/models/base'
      autoload :Build, 'dbsnp/rdf/models/build'
      autoload :Frequency, 'dbsnp/rdf/models/frequency'
      autoload :HgvsName, 'dbsnp/rdf/models/hgvs_name'
      autoload :Report, 'dbsnp/rdf/models/report'
      autoload :Significance, 'dbsnp/rdf/models/significance'
    end

    module Parser
      autoload :DbsnpXML, 'dbsnp/rdf/parser/dbsnp_xml'
    end

    module XML
      autoload :Dbsnp, 'dbsnp/rdf/xml/dbsnp'
    end
  end
end
