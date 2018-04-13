require 'spec_helper'

module Dbsnp::Rdf::Converter
  RSpec.describe RefsnpToTriples do
    it { expect(RefsnpToTriples).to respond_to(:convert).with(1).argument }

    describe '.convert' do
      let(:subject) { RefsnpToTriples.convert(refsnp) }
      let(:refsnp) { Dbsnp::Rdf::Parser::EntryParser.new(text).parse }
      let(:prefixes) { Dbsnp::Rdf::PREFIXES }

      context 'for examples/rs171.txt' do
        let(:text) { File.open(File.join(Dbsnp::Rdf::ROOT_DIR, 'spec', 'examples', 'rs171.txt')).read }
        let(:refsnp_uri) { RDF::URI.new("#{prefixes[:dbsnp]}rs171") }
        let(:refsnp_part_uri) { RDF::URI.new("#{prefixes[:dbsnp]}rs171#A-G") }


        it { is_expected.to be_a(Array) }

        it { is_expected.to all(be_a(RDF::Statement)) }

        it 'should have rdf triples' do
          is_expected.to include(RDF::Statement.new(refsnp_uri,
                                 RDF::Vocab::DC::identifier,
                                 "rs171"))

          is_expected.to include(RDF::Statement.new(refsnp_uri,
                                 RDF::type,
                                 Dbsnp::Rdf::Vocabularies::M2r.Variation))

          is_expected.to include(RDF::Statement.new(refsnp_uri,
                                 RDF::Vocab::DC::hasPart,
                                 refsnp_part_uri))

          is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                 RDF::type,
                                 Dbsnp::Rdf::Vocabularies::M2r.Variation))

          is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                 RDF::type,
                                 Dbsnp::Rdf::Vocabularies::Obo.SO_0001483))

          is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                 RDF::Vocab::DC::identifier,
                                 "rs171"))

          is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                    Dbsnp::Rdf::Vocabularies::Dbsnp.taxonomy,
                                                    RDF::URI.new(prefixes[:tax] + '9606')))

          is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                    Dbsnp::Rdf::Vocabularies::M2r.gene,
                                                    RDF::URI.new(prefixes[:ncbi_gene] + '64218')))

          is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                    Dbsnp::Rdf::Vocabularies::M2r.reference_allele,
                                                    'A'))

          is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                    Dbsnp::Rdf::Vocabularies::M2r.alternative_allele,
                                                    'G'))

          is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                    Dbsnp::Rdf::Vocabularies::M2r.alternative_allele,
                                                    'G'))
        end
      end
    end
  end
end
