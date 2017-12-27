RSpec.describe Dbsnp::RDF::XML::Dbsnp do
  context 'rs171.GRCh37p13.xml' do
    let(:entry) do
      Dbsnp::RDF::Parser::DbsnpXML.foreach('./examples/rs171.GRCh37p13.xml').first
    end

    context 'report' do
      describe '#rs' do
        it 'should return 171' do
          expect(entry.rs).to eq(171)
        end
      end

      describe '#snp_class' do
        it 'should return 171' do
          expect(entry.snp_class).to eq('snp')
        end
      end

      describe '#snp_type' do
        it 'should return notwithdrawn' do
          expect(entry.snp_type).to eq('notwithdrawn')
        end
      end

      describe '#mol_type' do
        it 'should return genomic' do
          expect(entry.mol_type).to eq('genomic')
        end
      end

      describe '#tax' do
        it 'should return 9606' do
          expect(entry.tax).to eq(9606)
        end
      end

      describe '#alleles' do
        it 'should return a allele' do
          expect(entry.alleles).to be_a(Enumerable)
          expect(entry.alleles.size).to eq(1)
        end
      end

      describe '#frequencies' do
        it 'should return no frequencies' do
          expect(entry.frequencies).to be_a(Enumerable)
          expect(entry.frequencies.size).to eq(0)
        end
      end

      describe '#builds' do
        it 'should return a build' do
          expect(entry.builds).to be_a(Enumerable)
          expect(entry.builds.size).to eq(1)
        end
      end

      describe '#hgvs_names' do
        it 'should return two hgvs_names' do
          expect(entry.hgvs_names).to be_a(Enumerable)
          expect(entry.hgvs_names.size).to eq(2)
        end
      end

      describe '#significances' do
        it 'should return no significances' do
          expect(entry.significances).to be_a(Enumerable)
          expect(entry.significances.size).to eq(0)
        end
      end
    end

    context 'alleles' do
      let(:allele) do
        entry.alleles.first
      end

      describe '#ref' do
        it 'should return T' do
          expect(allele.ref).to eq('T')
        end
      end

      describe '#alt' do
        it 'should return C' do
          expect(allele.alt).to eq('C')
        end
      end
    end

    context 'builds' do
      let(:build) do
        entry.builds.first
      end

      describe '#chr' do
        it 'should return 1' do
          expect(build.chr).to eq(1)
        end
      end

      describe '#position' do
        it 'should return 175261679' do
          expect(build.position).to eq(175261679)
        end
      end

      describe '#refseq' do
        it 'should return NC_000001.10' do
          expect(build.refseq).to eq('NC_000001.10')
        end
      end
    end

    context 'hgvs_names' do
      context 'first hgvs_name' do
        let(:hgvs_name) do
          entry.hgvs_names.first
        end

        describe '#name' do
          it 'should return NC_000001.10:g.175261679T>C' do
            expect(hgvs_name.name).to eq('NC_000001.10:g.175261679T>C')
          end
        end
      end

      context 'second hgvs_name' do
        let(:hgvs_name) do
          entry.hgvs_names.second
        end

        describe '#name' do
          it 'should return NC_000001.11:g.175292543T>C' do
            expect(hgvs_name.name).to eq('NC_000001.11:g.175292543T>C')
          end
        end
      end
    end
  end

  context 'rs171.GRCh38p7.xml' do
    let(:entry) do
      Dbsnp::RDF::Parser::DbsnpXML.foreach('./examples/rs171.GRCh38p7.xml').first
    end

    context 'report' do
      describe '#builds' do
        it 'should return a build' do
          expect(entry.builds).to be_a(Enumerable)
          expect(entry.builds.size).to eq(1)
        end
      end
    end

    context 'builds' do
      let(:build) do
        entry.builds.first
      end

      describe '#chr' do
        it 'should return 1' do
          expect(build.chr).to eq(1)
        end
      end

      describe '#position' do
        it 'should return 175261679' do
          expect(build.position).to eq(175292543)
        end
      end

      describe '#refseq' do
        it 'should return NC_000001.10' do
          expect(build.refseq).to eq('NC_000001.11')
        end
      end
    end
  end

  context 'rs665.GRCh37p13.xml' do
    let(:entry) do
      Dbsnp::RDF::Parser::DbsnpXML.foreach('./examples/rs665.GRCh37p13.xml').first
    end

    context 'report' do
      describe '#significances' do
        it 'should return a significance' do
          expect(entry.significances).to be_a(Enumerable)
          expect(entry.significances.size).to eq(1)
        end
      end

      describe '#frequencies' do
        it 'should return a frequency' do
          expect(entry.frequencies).to be_a(Enumerable)
          expect(entry.frequencies.size).to eq(1)
        end
      end
    end

    context 'significances' do
      let(:significance) do
        entry.significances.first
      end

      describe '#name' do
        it 'should return Likely benign' do
          expect(significance.name).to eq('Likely benign')
        end
      end
    end

    context 'frequencies' do
      let(:frequency) do
        entry.frequencies.first
      end

      describe '#frequency' do
        it 'should return 0.001' do
          expect(frequency.frequency).to be_within(0.001).of(0.001)
        end
      end

      describe '#allele' do
        it 'should return C' do
          expect(frequency.allele).to eq('T')
        end
      end

      describe '#sample_size' do
        it 'should return 5008' do
          expect(frequency.sample_size).to eq(5008)
        end
      end
    end
  end

  context 'rs1003725.GRCh37p13.xml' do
    let(:entry) do
      Dbsnp::RDF::Parser::DbsnpXML.foreach('./examples/rs1003725.GRCh37p13.xml').first
    end

    context 'report' do
      describe '#alleles' do
        it 'should return two alleles' do
          expect(entry.alleles).to be_a(Enumerable)
          expect(entry.alleles.size).to eq(2)
        end
      end

      describe '#frequencies' do
        it 'should return a frequency' do
          expect(entry.frequencies).to be_a(Enumerable)
          expect(entry.frequencies.size).to eq(1)
        end
      end
    end

    context 'alleles' do
      context 'first allele' do
        let(:allele) do
          entry.alleles.first
        end

        describe '#ref' do
          it 'should return G' do
            expect(allele.ref).to eq('G')
          end
        end

        describe '#alt' do
          it 'should return C' do
            expect(allele.alt).to eq('C')
          end
        end
      end

      context 'second allele' do
        let(:allele) do
          entry.alleles.second
        end

        describe '#ref' do
          it 'should return G' do
            expect(allele.ref).to eq('G')
          end
        end

        describe '#alt' do
          it 'should return T' do
            expect(allele.alt).to eq('T')
          end
        end
      end
    end

    context 'frequencies' do
      let(:frequency) do
        entry.frequencies.first
      end

      describe '#frequency' do
        it 'should return 0.0164' do
          expect(frequency.frequency).to be_within(0.0001).of(0.0164)
        end
      end

      describe '#allele' do
        it 'should return C' do
          expect(frequency.allele).to eq('C')
        end
      end

      describe '#sample_size' do
        it 'should return 5008' do
          expect(frequency.sample_size).to eq(5008)
        end
      end
    end
  end

end
