require 'spec_helper'

module DbSNP::RDF
  module Converter
    RSpec.describe VariationToTriples do
      it { expect(VariationToTriples).to respond_to(:convert).with(1).argument }

      describe '.convert' do
        let(:subject) { VariationToTriples.convert(variation) }

        context 'for three_snps.vcf' do
          let(:variations) do
            Parser::EntrySplitter.open(File.join('spec', 'examples', 'vcf', 'three_snps.vcf')).map do |entry|
              Parser::VCFParser.parse(entry)
            end
          end

          context 'for rs775809821' do
            let(:variation) { variations[0] }
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
                                                        Vocabularies::SNPO.taxonomy,
                                                        RDF::URI.new(PREFIXES[:tax] + '9606')))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r.reference_allele,
                                                        'TA'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r.alternative_allele,
                                                        'T'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::SNPO.hgvs,
                                                        'NC_000001.10:g.10020delA'))

              faldo_nodes = subject.select do |statement|
                statement.subject == refsnp_uri && statement.predicate == Vocabularies::Faldo.location
              end.map(&:object)

              expect(faldo_nodes.count).to eq(1)

              expect(faldo_nodes.any? do |faldo_node|
                begin_subject = subject.select do |statement|
                  statement.subject == faldo_node && statement.predicate == Vocabularies::Faldo.begin
                end[0].object

                end_subject = subject.select do |statement|
                  statement.subject == faldo_node && statement.predicate == Vocabularies::Faldo.end
                end[0].object
                subject.include?(RDF::Statement.new(faldo_node, RDF::type, Vocabularies::Faldo.Region)) &&
                    subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.begin, begin_subject)) &&
                    subject.include?(RDF::Statement.new(begin_subject, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                    subject.include?(RDF::Statement.new(begin_subject, Vocabularies::Faldo.position, 10019)) &&
                    subject.include?(RDF::Statement.new(begin_subject, Vocabularies::Faldo.reference, RDF::URI.new(PREFIXES[:refseq] + 'NC_000001.10'))) &&
                    subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.end, end_subject)) &&
                    subject.include?(RDF::Statement.new(end_subject, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                    subject.include?(RDF::Statement.new(end_subject, Vocabularies::Faldo.position, 10020)) &&
                    subject.include?(RDF::Statement.new(end_subject, Vocabularies::Faldo.reference, RDF::URI.new(PREFIXES[:refseq] + 'NC_000001.10')))
              end
              ).to eq(true)
            end
          end


          context 'for rs978760828' do
            let(:refsnp_uri) { RDF::URI.new("#{PREFIXES[:dbsnp]}rs978760828") }
            let(:variation) { variations[1] }

            it 'should have rdf triples' do
              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::Vocab::DC::identifier,
                                                        "rs978760828"))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::type,
                                                        Vocabularies::M2r.Variation))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::type,
                                                        Vocabularies::Obo.SO_0001483))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::SNPO.taxonomy,
                                                        RDF::URI.new(PREFIXES[:tax] + '9606')))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r.reference_allele,
                                                        'A'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r.alternative_allele,
                                                        'C'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::SNPO.hgvs,
                                                        'NC_000001.10:g.10039A>C'))

              faldo_nodes = subject.select do |statement|
                statement.subject == refsnp_uri && statement.predicate == Vocabularies::Faldo.location
              end.map(&:object)

              expect(faldo_nodes.count).to eq(1)

              expect(faldo_nodes.any? do |faldo_node|
                subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.position, 10039)) &&
                    subject.include?(RDF::Statement.new(faldo_node, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                    subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.reference, RDF::URI.new(PREFIXES[:refseq] + 'NC_000001.10')))
              end
              ).to eq(true)

            end
          end

          context 'for rs1008829651' do
            let(:refsnp_uri) { RDF::URI.new("#{PREFIXES[:dbsnp]}rs1008829651") }
            let(:variation) { variations[2] }

            it 'should have rdf triples' do
              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::Vocab::DC::identifier,
                                                        "rs1008829651"))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::type,
                                                        Vocabularies::M2r.Variation))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::type,
                                                        Vocabularies::Obo.SO_0001483))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::SNPO.taxonomy,
                                                        RDF::URI.new(PREFIXES[:tax] + '9606')))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r.reference_allele,
                                                        'T'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r.alternative_allele,
                                                        'A'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::SNPO.hgvs,
                                                        'NC_000001.10:g.10043T>A'))

              faldo_nodes = subject.select do |statement|
                statement.subject == refsnp_uri && statement.predicate == Vocabularies::Faldo.location
              end.map(&:object)

              expect(faldo_nodes.count).to eq(1)

              expect(faldo_nodes.any? do |faldo_node|
                subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.position, 10043)) &&
                    subject.include?(RDF::Statement.new(faldo_node, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                    subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.reference, RDF::URI.new(PREFIXES[:refseq] + 'NC_000001.10')))
              end
              ).to eq(true)

            end
          end
        end

        context 'for single line vcfs' do
          let(:variation) { Parser::VCFParser.parse(text) }

          context 'for rs200462216.vcf' do
            let(:text) { File.read(File.join('spec', 'examples', 'vcf', 'rs200462216.vcf')) }

            it { is_expected.to be_a(Array) }

            it { is_expected.to all(be_a(RDF::Statement)) }
            let(:refsnp_uri) { RDF::URI.new("#{PREFIXES[:dbsnp]}rs200462216") }

            it 'should have rdf triples' do
              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::Vocab::DC::identifier,
                                                        "rs200462216"))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::type,
                                                        Vocabularies::M2r.Variation))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::type,
                                                        Vocabularies::Obo.SO_1000032))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::SNPO.taxonomy,
                                                        RDF::URI.new(PREFIXES[:tax] + '9606')))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r.reference_allele,
                                                        'TAACCCCTAACCCTAACCCTAAACCCTA'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r.alternative_allele,
                                                        'T'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::SNPO.hgvs,
                                                        'NC_000001.11:g.10229_10255delAACCCCTAACCCTAACCCTAAACCCTA'))

              faldo_nodes = subject.select do |statement|
                statement.subject == refsnp_uri && statement.predicate == Vocabularies::Faldo.location
              end.map(&:object)

              expect(faldo_nodes.count).to eq(1)

              expect(faldo_nodes.any? do |faldo_node|
                begin_subject = subject.select do |statement|
                  statement.subject == faldo_node && statement.predicate == Vocabularies::Faldo.begin
                end[0].object

                end_subject = subject.select do |statement|
                  statement.subject == faldo_node && statement.predicate == Vocabularies::Faldo.end
                end[0].object
                subject.include?(RDF::Statement.new(faldo_node, RDF::type, Vocabularies::Faldo.Region)) &&
                    subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.begin, begin_subject)) &&
                    subject.include?(RDF::Statement.new(begin_subject, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                    subject.include?(RDF::Statement.new(begin_subject, Vocabularies::Faldo.position, 10228)) &&
                    subject.include?(RDF::Statement.new(begin_subject, Vocabularies::Faldo.reference, RDF::URI.new(PREFIXES[:refseq] + 'NC_000001.11'))) &&
                    subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.end, end_subject)) &&
                    subject.include?(RDF::Statement.new(end_subject, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                    subject.include?(RDF::Statement.new(end_subject, Vocabularies::Faldo.position, 10255)) &&
                    subject.include?(RDF::Statement.new(end_subject, Vocabularies::Faldo.reference, RDF::URI.new(PREFIXES[:refseq] + 'NC_000001.11')))
              end
              ).to eq(true)
            end
          end

          context 'for rs71286109.vcf' do
            let(:text) { File.read(File.join('spec', 'examples', 'vcf', 'rs71286109.vcf')) }
            it { is_expected.to be_a(Array) }

            it { is_expected.to all(be_a(RDF::Statement)) }
            let(:refsnp_uri) { RDF::URI.new("#{PREFIXES[:dbsnp]}rs71286109") }

            it 'should have rdf triples' do
              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::Vocab::DC::identifier,
                                                        "rs71286109"))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::type,
                                                        Vocabularies::M2r.Variation))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::type,
                                                        Vocabularies::Obo.SO_0000667))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::SNPO.taxonomy,
                                                        RDF::URI.new(PREFIXES[:tax] + '9606')))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r::gene,
                                                        RDF::URI.new(PREFIXES[:ncbi_gene] + '102466751')))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r.reference_allele,
                                                        'C'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r.alternative_allele,
                                                        'CCA'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::SNPO.hgvs,
                                                        'NC_000001.11:g.17492_17493insCA'))

              faldo_nodes = subject.select do |statement|
                statement.subject == refsnp_uri && statement.predicate == Vocabularies::Faldo.location
              end.map(&:object)

              expect(faldo_nodes.count).to eq(1)

              expect(faldo_nodes.any? do |faldo_node|
                subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.position, 17492)) &&
                    subject.include?(RDF::Statement.new(faldo_node, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                    subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.reference, RDF::URI.new(PREFIXES[:refseq] + 'NC_000001.11')))
              end
              ).to eq(true)
            end
          end

          context 'for rs672601345.vcf' do
            let(:text) { File.read(File.join('spec', 'examples', 'vcf', 'rs672601345.vcf')) }
            it { is_expected.to be_a(Array) }

            it { is_expected.to all(be_a(RDF::Statement)) }
            let(:refsnp_uri) { RDF::URI.new("#{PREFIXES[:dbsnp]}rs672601345") }

            it 'should have rdf triples' do
              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::Vocab::DC::identifier,
                                                        "rs672601345"))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::type,
                                                        Vocabularies::M2r.Variation))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::type,
                                                        Vocabularies::Obo.SO_1000032))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::SNPO.taxonomy,
                                                        RDF::URI.new(PREFIXES[:tax] + '9606')))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r::gene,
                                                        RDF::URI.new(PREFIXES[:ncbi_gene] + '9636')))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r.reference_allele,
                                                        'C'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r.alternative_allele,
                                                        'CG'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::SNPO.clinical_significance,
                                                        'Pathogenic'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::SNPO.hgvs,
                                                        'NC_000001.10:g.949699dup'))

              faldo_nodes = subject.select do |statement|
                statement.subject == refsnp_uri && statement.predicate == Vocabularies::Faldo.location
              end.map(&:object)

              expect(faldo_nodes.count).to eq(1)

              expect(faldo_nodes.any? do |faldo_node|
                subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.position, 949696)) &&
                    subject.include?(RDF::Statement.new(faldo_node, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                    subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.reference, RDF::URI.new(PREFIXES[:refseq] + 'NC_000001.10')))
              end
              ).to eq(true)
            end


            context 'for rs797044840.vcf' do
              let(:text) { File.read(File.join('spec', 'examples', 'vcf', 'rs797044840.vcf')) }
              it { is_expected.to be_a(Array) }

              it { is_expected.to all(be_a(RDF::Statement)) }
              let(:refsnp_uri) { RDF::URI.new("#{PREFIXES[:dbsnp]}rs797044840") }

              it 'should have rdf triples' do
                is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                          RDF::Vocab::DC::identifier,
                                                          "rs797044840"))

                is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                          RDF::type,
                                                          Vocabularies::M2r.Variation))

                is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                          RDF::type,
                                                          Vocabularies::Obo.SO_1000032))

                is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                          Vocabularies::SNPO.taxonomy,
                                                          RDF::URI.new(PREFIXES[:tax] + '9606')))

                is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                          Vocabularies::M2r::gene,
                                                          RDF::URI.new(PREFIXES[:ncbi_gene] + '1855')))

                is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                          Vocabularies::M2r.reference_allele,
                                                          'GTAGGCAGG'))

                is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                          Vocabularies::M2r.alternative_allele,
                                                          'GC'))

                is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                          Vocabularies::SNPO.clinical_significance,
                                                          'Pathogenic'))

                is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                          Vocabularies::SNPO.hgvs,
                                                          'NC_000001.10:g.1273413_1273420delTAGGCAGGinsC'))

                faldo_nodes = subject.select do |statement|
                  statement.subject == refsnp_uri && statement.predicate == Vocabularies::Faldo.location
                end.map(&:object)

                expect(faldo_nodes.count).to eq(1)

                expect(faldo_nodes.any? do |faldo_node|
                  begin_subject = subject.select do |statement|
                    statement.subject == faldo_node && statement.predicate == Vocabularies::Faldo.begin
                  end[0].object

                  end_subject = subject.select do |statement|
                    statement.subject == faldo_node && statement.predicate == Vocabularies::Faldo.end
                  end[0].object

                  subject.include?(RDF::Statement.new(faldo_node, RDF::type, Vocabularies::Faldo.Region)) &&
                      subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.begin, begin_subject)) &&
                      subject.include?(RDF::Statement.new(begin_subject, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                      subject.include?(RDF::Statement.new(begin_subject, Vocabularies::Faldo.position, 1273412)) &&
                      subject.include?(RDF::Statement.new(begin_subject, Vocabularies::Faldo.reference, RDF::URI.new(PREFIXES[:refseq] + 'NC_000001.10'))) &&
                      subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.end, end_subject)) &&
                      subject.include?(RDF::Statement.new(end_subject, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                      subject.include?(RDF::Statement.new(end_subject, Vocabularies::Faldo.position, 1273420)) &&
                      subject.include?(RDF::Statement.new(end_subject, Vocabularies::Faldo.reference, RDF::URI.new(PREFIXES[:refseq] + 'NC_000001.10')))
                end
                ).to eq(true)
              end
            end

            context 'for rs553355578.vcf' do
              let(:text) { File.read(File.join('spec', 'examples', 'vcf', 'rs553355578.vcf')) }
              it { is_expected.to be_a(Array) }

              it { is_expected.to all(be_a(RDF::Statement)) }
              let(:refsnp_uri) { RDF::URI.new("#{PREFIXES[:dbsnp]}rs553355578") }

              it 'should have rdf triples' do
                is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                          RDF::Vocab::DC::identifier,
                                                          "rs553355578"))

                is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                          RDF::type,
                                                          Vocabularies::M2r.Variation))
              end

              context 'for A-C' do
                let(:refsnp_part_uri) { refsnp_uri + '#A-C' }

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
                                                            Vocabularies::SNPO.taxonomy,
                                                            RDF::URI.new(PREFIXES[:tax] + '9606')))

                  is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                            Vocabularies::M2r.reference_allele,
                                                            'A'))

                  is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                            Vocabularies::M2r.alternative_allele,
                                                            'C'))

                  is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                            Vocabularies::SNPO.hgvs,
                                                            'NC_000001.10:g.133198A>C'))

                  faldo_nodes = subject.select do |statement|
                    statement.subject == refsnp_part_uri && statement.predicate == Vocabularies::Faldo.location
                  end.map(&:object)

                  expect(faldo_nodes.count).to eq(1)

                  expect(faldo_nodes.any? do |faldo_node|
                    subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.position, 133198)) &&
                        subject.include?(RDF::Statement.new(faldo_node, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                        subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.reference, RDF::URI.new(PREFIXES[:refseq] + 'NC_000001.10')))
                  end
                  ).to eq(true)
                end
              end


              context 'for A-G' do
                let(:refsnp_part_uri) { refsnp_uri + '#A-G' }

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
                                                            Vocabularies::SNPO.taxonomy,
                                                            RDF::URI.new(PREFIXES[:tax] + '9606')))

                  is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                            Vocabularies::M2r.reference_allele,
                                                            'A'))

                  is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                            Vocabularies::M2r.alternative_allele,
                                                            'G'))

                  frequency_nodes = subject.select do |statement|
                    statement.subject == refsnp_part_uri && statement.predicate == Vocabularies::SNPO.frequency
                  end.map(&:object)

                  expect(frequency_nodes.count).to eq(1)

                  frequency_node = frequency_nodes[0]

                  is_expected.to include(RDF::Statement.new(frequency_node, RDF::type, Vocabularies::SNPO.Frequency))

                  is_expected.to include(RDF::Statement.new(frequency_node, RDF::type, Vocabularies::SNPO.send('1000GenomesFrequency')))

                  is_expected.to include(RDF::Statement.new(frequency_node, RDF::value, 0.0003994))

                  is_expected.to include(RDF::Statement.new(refsnp_part_uri,
                                                            Vocabularies::SNPO.hgvs,
                                                            'NC_000001.10:g.133198A>G'))

                  faldo_nodes = subject.select do |statement|
                    statement.subject == refsnp_part_uri && statement.predicate == Vocabularies::Faldo.location
                  end.map(&:object)

                  expect(faldo_nodes.count).to eq(1)

                  expect(faldo_nodes.any? do |faldo_node|
                    subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.position, 133198)) &&
                        subject.include?(RDF::Statement.new(faldo_node, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                        subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.reference, RDF::URI.new(PREFIXES[:refseq] + 'NC_000001.10')))
                  end
                  ).to eq(true)
                end
              end
            end
          end

          context 'for a line with invalid variation class' do
            let(:text) { File.read(File.join('spec', 'examples', 'vcf', 'invalid_vc.vcf')) }

            it 'should raise ValidationError' do
              expect { VariationToTriples.convert(variation) }.to raise_error(ValidationError)
            end
          end

          context 'for rs539283387.vcf' do
            let(:text) { File.read(File.join('spec', 'examples', 'vcf', 'rs539283387.vcf')) }

            it { is_expected.to be_a(Array) }

            it { is_expected.to all(be_a(RDF::Statement)) }
            let(:refsnp_uri) { RDF::URI.new("#{PREFIXES[:dbsnp]}rs539283387") }

            it 'should have rdf triples' do
              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::Vocab::DC::identifier,
                                                        "rs539283387"))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::type,
                                                        Vocabularies::M2r.Variation))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        RDF::type,
                                                        Vocabularies::Obo.SO_0001483))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::SNPO.taxonomy,
                                                        RDF::URI.new(PREFIXES[:tax] + '9606')))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r::gene,
                                                        RDF::URI.new(PREFIXES[:ncbi_gene] + '375790')))

              frequency_nodes = subject.select do |statement|
                statement.subject == refsnp_uri && statement.predicate == Vocabularies::SNPO.frequency
              end.map(&:object)

              expect(frequency_nodes.count).to eq(4)

              expect(frequency_nodes.any? do |frequency_node|
                subject.include?(RDF::Statement.new(frequency_node, RDF::type, Vocabularies::SNPO.Frequency)) &&
                    subject.include?(RDF::Statement.new(frequency_node, RDF::type, Vocabularies::SNPO.send('1000GenomesFrequency'))) &&
                    subject.include?(RDF::Statement.new(frequency_node, RDF::value, 0.009585))
              end).to eq(true)

              expect(frequency_nodes.any? do |frequency_node|
                subject.include?(RDF::Statement.new(frequency_node, RDF::type, Vocabularies::SNPO.Frequency)) &&
                    subject.include?(RDF::Statement.new(frequency_node, RDF::type, Vocabularies::SNPO.ExacFrequency)) &&
                    subject.include?(RDF::Statement.new(frequency_node, RDF::value, 0.001141))
              end).to eq(true)

              expect(frequency_nodes.any? do |frequency_node|
                subject.include?(RDF::Statement.new(frequency_node, RDF::type, Vocabularies::SNPO.Frequency)) &&
                    subject.include?(RDF::Statement.new(frequency_node, RDF::type, Vocabularies::SNPO.GnomadFrequency)) &&
                    subject.include?(RDF::Statement.new(frequency_node, RDF::value, 0.01169))
              end).to eq(true)

              expect(frequency_nodes.any? do |frequency_node|
                subject.include?(RDF::Statement.new(frequency_node, RDF::type, Vocabularies::SNPO.Frequency)) &&
                    subject.include?(RDF::Statement.new(frequency_node, RDF::type, Vocabularies::SNPO.TopmedFrequency)) &&
                    subject.include?(RDF::Statement.new(frequency_node, RDF::value, 0.01892))
              end).to eq(true)

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r.reference_allele,
                                                        'G'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::M2r.alternative_allele,
                                                        'C'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::SNPO.clinical_significance,
                                                        'Benign'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::SNPO.clinical_significance,
                                                        'Likely benign'))

              is_expected.to include(RDF::Statement.new(refsnp_uri,
                                                        Vocabularies::SNPO.hgvs,
                                                        'NC_000001.10:g.955563G>C'))

              faldo_nodes = subject.select do |statement|
                statement.subject == refsnp_uri && statement.predicate == Vocabularies::Faldo.location
              end.map(&:object)

              expect(faldo_nodes.count).to eq(1)

              expect(faldo_nodes.any? do |faldo_node|
                subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.position, 955563)) &&
                    subject.include?(RDF::Statement.new(faldo_node, RDF::type, Vocabularies::Faldo.ExactPosition)) &&
                    subject.include?(RDF::Statement.new(faldo_node, Vocabularies::Faldo.reference, RDF::URI.new(PREFIXES[:refseq] + 'NC_000001.10')))
              end
              ).to eq(true)
            end
          end
        end
      end
    end
  end
end