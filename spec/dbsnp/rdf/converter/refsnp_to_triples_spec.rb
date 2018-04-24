require 'spec_helper'

module DbSNP::RDF
  module Converter
    RSpec.describe RefsnpToTriples do
      it { expect(RefsnpToTriples).to respond_to(:convert).with(1).argument }

      describe '.convert' do
        let(:subject) { RefsnpToTriples.convert(refsnp) }
        let(:prefixes) { PREFIXES }
        let(:refsnps) { Parser::XmlParser.open(File.join('spec', 'examples', 'xml', '171_242_538.xml')).to_a }

        context 'for rs171' do
          let(:refsnp) { refsnps[0] }
          it { is_expected.to be_a(Array) }

          it { is_expected.to all(be_a(RDF::Statement)) }
          let(:refsnp_uri) { RDF::URI.new("#{prefixes[:dbsnp]}rs171") }
          let(:refsnp_part_uri) { RDF::URI.new("#{prefixes[:dbsnp]}rs171#T-C") }

          it 'should have rdf triples' do
            is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                      RDF::Vocab::DC::identifier,
                                                      "rs171"))

            is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                      RDF::type,
                                                      Vocabularies::M2r.Variation))

            is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                      RDF::Vocab::DC::hasPart,
                                                      refsnp_part_uri))

            is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                      RDF::type,
                                                      Vocabularies::M2r.Variation))

            is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                      RDF::type,
                                                      Vocabularies::Obo.SO_0001483))

            is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                      RDF::Vocab::DC::identifier,
                                                      "rs171"))

            is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                      Vocabularies::DbSNP.taxonomy,
                                                      RDF::URI.new(prefixes[:tax] + '9606')))

            is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                      Vocabularies::M2r.reference_allele,
                                                      'T'))

            is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                      Vocabularies::M2r.alternative_allele,
                                                      'C'))

            is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                      Vocabularies::Snpo.hgvs,
                                                      'NC_000001.11:g.175292543T>C'))

            is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                      Vocabularies::Snpo.hgvs,
                                                      'NC_000001.10:g.175261679T>C'))

            faldo_subjects = subject.select do |statement|
              statement.subject == refsnp_part_uri && statement.predicate == Vocabularies::Faldo.location
            end.map(&:object)

            expect(faldo_subjects.count).to eq(2)

            expect(faldo_subjects.any? do |faldo_subject|
              subject.include?(RDF::Statement.new(faldo_subject, Vocabularies::Faldo.position, 175261679)) &&
                  subject.include?(RDF::Statement.new(faldo_subject, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                  subject.include?(RDF::Statement.new(faldo_subject, Vocabularies::Faldo.reference, RDF::URI.new(prefixes[:refseq] + 'NC_000001.10')))
            end
            ).to eq(true)

            expect(faldo_subjects.any? do |faldo_subject|
              subject.include?(RDF::Statement.new(faldo_subject, Vocabularies::Faldo.position, 175292543)) &&
                  subject.include?(RDF::Statement.new(faldo_subject, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                  subject.include?(RDF::Statement.new(faldo_subject, Vocabularies::Faldo.reference, RDF::URI.new(prefixes[:refseq] + 'NC_000001.11')))
            end
            ).to eq(true)
          end

          context 'for rs242' do
            let(:refsnp_uri) { RDF::URI.new("#{prefixes[:dbsnp]}rs242") }
            let(:refsnp_part_uri) { RDF::URI.new("#{prefixes[:dbsnp]}rs242#delT") }
            let(:refsnp) { refsnps[1] }

            it 'should have rdf triples' do
              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::Vocab::DC::identifier,
                                                        "rs242"))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::type,
                                                        Vocabularies::M2r.Variation))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::Vocab::DC::hasPart,
                                                        refsnp_part_uri))

              is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                        RDF::type,
                                                        Vocabularies::M2r.Variation))

              is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                        RDF::type,
                                                        Vocabularies::Obo.SO_1000032))

              is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                        RDF::Vocab::DC::identifier,
                                                        "rs242"))

              is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                        Vocabularies::DbSNP.taxonomy,
                                                        RDF::URI.new(prefixes[:tax] + '9606')))

              is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                        Vocabularies::M2r.reference_allele,
                                                        'T'))

              is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                        Vocabularies::M2r.alternative_allele,
                                                        '-'))

              is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                        Vocabularies::Snpo.hgvs,
                                                        'NC_000001.11:g.20542968delT'))

              is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                        Vocabularies::Snpo.hgvs,
                                                        'NC_000001.10:g.20869461delT'))

              is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                        Vocabularies::Snpo.frequency,
                                                        0.0513))

              is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                        Vocabularies::Snpo.sample_size,
                                                        5008))

              faldo_subjects = subject.select do |statement|
                statement.subject == refsnp_part_uri && statement.predicate == Vocabularies::Faldo.location
              end.map(&:object)

              expect(faldo_subjects.count).to eq(2)


              expect(faldo_subjects.any? do |faldo_subject|
                subject.include?(RDF::Statement.new(faldo_subject, Vocabularies::Faldo.position, 20869461)) &&
                    subject.include?(RDF::Statement.new(faldo_subject, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                    subject.include?(RDF::Statement.new(faldo_subject, Vocabularies::Faldo.reference, RDF::URI.new(prefixes[:refseq] + 'NC_000001.10')))
              end
              ).to eq(true)

              expect(faldo_subjects.any? do |faldo_subject|
                subject.include?(RDF::Statement.new(faldo_subject, Vocabularies::Faldo.position, 20542968)) &&
                    subject.include?(RDF::Statement.new(faldo_subject, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                    subject.include?(RDF::Statement.new(faldo_subject, Vocabularies::Faldo.reference, RDF::URI.new(prefixes[:refseq] + 'NC_000001.11')))
              end
              ).to eq(true)

            end
          end

          context 'for rs538' do
            let(:refsnp_uri) { RDF::URI.new("#{prefixes[:dbsnp]}rs538") }
            let(:refsnp) { refsnps[2] }

            it { is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                      RDF::Vocab::DC::identifier,
                                                      "rs538")) }

            it { is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                      RDF::type,
                                                      Vocabularies::M2r.Variation)) }

            context 'for rs538A>C' do
              let(:refsnp_part_uri) { RDF::URI.new("#{prefixes[:dbsnp]}rs538#A-C") }

              it 'should have rdf triples' do

                is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                          RDF::Vocab::DC::hasPart,
                                                          refsnp_part_uri))

                is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                          RDF::type,
                                                          Vocabularies::M2r.Variation))

                is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                          RDF::type,
                                                          Vocabularies::Obo.SO_0001483))

                is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                          RDF::Vocab::DC::identifier,
                                                          "rs538"))

                is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                          Vocabularies::DbSNP.taxonomy,
                                                          RDF::URI.new(prefixes[:tax] + '9606')))

                is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                          Vocabularies::M2r.gene,
                                                          RDF::URI.new(prefixes[:ncbi_gene] + '8514')))

                is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                          Vocabularies::M2r.reference_allele,
                                                          'A'))

                is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                          Vocabularies::M2r.alternative_allele,
                                                          'C'))

                is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                          Vocabularies::Snpo.hgvs,
                                                          'NC_000001.10:g.6160958A>C'))

                is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                          Vocabularies::Snpo.hgvs,
                                                          'NC_000001.11:g.6100898A>C'))

                is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                          Vocabularies::Snpo.frequency,
                                                          0.2091))

                is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                          Vocabularies::Snpo.sample_size,
                                                          5008))

                faldo_subjects = subject.select do |statement|
                  statement.subject == refsnp_part_uri && statement.predicate == Vocabularies::Faldo.location
                end.map(&:object)

                expect(faldo_subjects.count).to eq(2)


                expect(faldo_subjects.any? do |faldo_subject|
                  subject.include?(RDF::Statement.new(faldo_subject, Vocabularies::Faldo.position, 6160958)) &&
                      subject.include?(RDF::Statement.new(faldo_subject, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                      subject.include?(RDF::Statement.new(faldo_subject, Vocabularies::Faldo.reference, RDF::URI.new(prefixes[:refseq] + 'NC_000001.10')))
                end
                ).to eq(true)

                expect(faldo_subjects.any? do |faldo_subject|
                  subject.include?(RDF::Statement.new(faldo_subject, Vocabularies::Faldo.position, 6100898)) &&
                      subject.include?(RDF::Statement.new(faldo_subject, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                      subject.include?(RDF::Statement.new(faldo_subject, Vocabularies::Faldo.reference, RDF::URI.new(prefixes[:refseq] + 'NC_000001.11')))
                end
                ).to eq(true)

              end
            end


          end
        end
      end
    end
  end
end