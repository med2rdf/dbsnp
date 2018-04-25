require 'spec_helper'

module DbSNP::RDF
  module Converter
    RSpec.describe RefsnpToTriples do
      it { expect(RefsnpToTriples).to respond_to(:convert).with(1).argument }

      describe '.convert' do
        let(:subject) { RefsnpToTriples.convert(refsnp) }
        let(:refsnps) { Parser::VCFParser.open(File.join('spec', 'examples', 'vcf', 'three_snps.vcf')).each.to_a }

        context 'for rs775809821' do
          let(:refsnp) { refsnps[0] }
          it { is_expected.to be_a(Array) }

          it { is_expected.to all(be_a(RDF::Statement)) }
          let(:refsnp_uri) { RDF::URI.new("#{PREFIXES[:dbsnp]}rs775809821") }

          it 'should have rdf triples' do
            is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                      RDF::Vocab::DC::identifier,
                                                      "rs775809821"))

            is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                      RDF::type,
                                                      Vocabularies::M2r.Variation))

            is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                      RDF::type,
                                                      Vocabularies::Obo.SO_1000032))

            is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                      Vocabularies::DbSNP.taxonomy,
                                                      RDF::URI.new(PREFIXES[:tax] + '9606')))

            is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                      Vocabularies::M2r.reference_allele,
                                                      'TA'))

            is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                      Vocabularies::M2r.alternative_allele,
                                                      'T'))

            is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                      Vocabularies::Snpo.hgvs,
                                                      'NC_000001.10:g.10020delA'))

            faldo_subjects = subject.select do |statement|
              statement.subject == refsnp_uri && statement.predicate == Vocabularies::Faldo.location
            end.map(&:object)

            expect(faldo_subjects.count).to eq(1)

            expect(faldo_subjects.any? do |faldo_subject|
              subject.include?(RDF::Statement.new(faldo_subject, Vocabularies::Faldo.position, 10019)) &&
                  subject.include?(RDF::Statement.new(faldo_subject, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                  subject.include?(RDF::Statement.new(faldo_subject, Vocabularies::Faldo.reference, RDF::URI.new(PREFIXES[:refseq] + 'NC_000001.10')))
            end
            ).to eq(true)
          end


          context 'for rs978760828' do
            let(:refsnp_uri) { RDF::URI.new("#{PREFIXES[:dbsnp]}rs978760828") }
            let(:refsnp) { refsnps[1] }

            it 'should have rdf triples' do
              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::Vocab::DC::identifier,
                                                        "rs978760828"))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::type,
                                                        Vocabularies::M2r.Variation))


              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::type,
                                                        Vocabularies::M2r.Variation))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::type,
                                                        Vocabularies::Obo.SO_0001483))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::DbSNP.taxonomy,
                                                        RDF::URI.new(PREFIXES[:tax] + '9606')))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r.reference_allele,
                                                        'A'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r.alternative_allele,
                                                        'C'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::Snpo.hgvs,
                                                        'NC_000001.10:g.10039A>C'))

              faldo_subjects = subject.select do |statement|
                statement.subject == refsnp_uri && statement.predicate == Vocabularies::Faldo.location
              end.map(&:object)

              expect(faldo_subjects.count).to eq(1)

              expect(faldo_subjects.any? do |faldo_subject|
                subject.include?(RDF::Statement.new(faldo_subject, Vocabularies::Faldo.position, 10039)) &&
                    subject.include?(RDF::Statement.new(faldo_subject, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                    subject.include?(RDF::Statement.new(faldo_subject, Vocabularies::Faldo.reference, RDF::URI.new(PREFIXES[:refseq] + 'NC_000001.10')))
              end
              ).to eq(true)

            end
          end

          context 'for rs1008829651' do
            let(:refsnp_uri) { RDF::URI.new("#{PREFIXES[:dbsnp]}rs1008829651") }
            let(:refsnp) { refsnps[2] }

            it 'should have rdf triples' do
              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::Vocab::DC::identifier,
                                                        "rs1008829651"))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::type,
                                                        Vocabularies::M2r.Variation))


              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::type,
                                                        Vocabularies::M2r.Variation))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::type,
                                                        Vocabularies::Obo.SO_0001483))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::DbSNP.taxonomy,
                                                        RDF::URI.new(PREFIXES[:tax] + '9606')))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r.reference_allele,
                                                        'T'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r.alternative_allele,
                                                        'A'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::Snpo.hgvs,
                                                        'NC_000001.10:g.10043T>A'))

              faldo_subjects = subject.select do |statement|
                statement.subject == refsnp_uri && statement.predicate == Vocabularies::Faldo.location
              end.map(&:object)

              expect(faldo_subjects.count).to eq(1)

              expect(faldo_subjects.any? do |faldo_subject|
                subject.include?(RDF::Statement.new(faldo_subject, Vocabularies::Faldo.position, 10043)) &&
                    subject.include?(RDF::Statement.new(faldo_subject, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                    subject.include?(RDF::Statement.new(faldo_subject, Vocabularies::Faldo.reference, RDF::URI.new(PREFIXES[:refseq] + 'NC_000001.10')))
              end
              ).to eq(true)

            end
          end
        end
      end
    end
  end
end