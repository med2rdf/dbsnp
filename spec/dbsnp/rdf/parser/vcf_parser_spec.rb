require 'rspec'

module DbSNP::RDF::Parser
  RSpec.describe VCFParser do
    it { expect(VCFParser).to respond_to(:parse).with(1).argument }

    describe '#parse' do
      let(:subject) { VCFParser.parse(text) }

      context 'for a line of rs775809821' do
        let(:text) { %w[NC_000001.10 10019 rs775809821 TA T . . RS=775809821;dbSNPBuildID=144;SSR=0;PSEUDOGENEINFO=DDX11L1:100287102;VC=INDEL].join("\t") }

        it { is_expected.to be_a(VCFParser::Variation) }

        it 'should have properties of VCFParser::Variation' do
          expect(subject.rs_id).to eq('rs775809821')
          expect(subject.variation_class).to eq('INDEL')
          expect(subject.gene_id_list).to eq([])
          expect(subject.reference_allele).to eq('TA')
          expect(subject.alternative_alleles).to eq(%w[T])
          expect(subject.frequency).to eq(nil)
          expect(subject.reference_sequence).to eq('NC_000001.10')
          expect(subject.position).to eq('10019')
          expect(subject.clinical_significance).to eq(nil)
          expect(subject.hgvs).to eq(nil)
        end
      end


      context 'for a line of rs537951473' do
        let(:text) { %w[NC_000001.10 13482 rs537951473 G A,C . . RS=537951473;dbSNPBuildID=142;SSR=0;PSEUDOGENEINFO=DDX11L1:100287102;VC=SNV;GNO;FREQ=1000Genomes:0.9996,.,0.0003994|ExAC:0.9998,.,0.0001704|GnomAD:1,.,0].join("\t") }

        it { is_expected.to be_a(VCFParser::Variation) }

        it 'should have properties of VCFParser::Variation' do
          expect(subject.rs_id).to eq('rs537951473')
          expect(subject.variation_class).to eq('SNV')
          expect(subject.gene_id_list).to eq([])
          expect(subject.reference_allele).to eq('G')
          expect(subject.alternative_alleles).to eq(%w[A C])
          expect(subject.frequency).to eq(['0.9996', nil, '0.0003994'])
          expect(subject.reference_sequence).to eq('NC_000001.10')
          expect(subject.position).to eq('13482')
          expect(subject.clinical_significance).to eq(nil)
          expect(subject.hgvs).to eq(nil)
        end
      end

      context 'for a line of rs61766284' do
        let(:text) { File.read(File.join('spec', 'examples', 'vcf', 'rs61766284.vcf')) }

        it { is_expected.to be_a(VCFParser::Variation) }

        it 'should have properties of VCFParser::Variation' do
          expect(subject.rs_id).to eq('rs61766284')
          expect(subject.variation_class).to eq('SNV')
          expect(subject.gene_id_list).to eq(['9636'])
          expect(subject.reference_allele).to eq('C')
          expect(subject.alternative_alleles).to eq(%w[G T])
          expect(subject.frequency).to eq(['0.9966', nil, '0.003395'])
          expect(subject.reference_sequence).to eq('NC_000001.11')
          expect(subject.position).to eq('1014217')
          expect(subject.clinical_significance).to eq([nil, nil, ['2']])
          expect(subject.hgvs).to eq(['NC_000001.11:g.1014217C=', 'NC_000001.11:g.1014217C>G', 'NC_000001.11:g.1014217C>T'])
        end
      end


      context 'for a line with invalid bytes' do
        let(:text) { (%w[NC_000001.10 10019 rs775809821 TA T . . RS=775809821;dbSNPBuildID=144;SSR=0;PSEUDOGENEINFO=DDX11L1:100287102;VC=INDEL].join("\t") + 0xff.chr).force_encoding('UTF-8') }

        it { is_expected.to be_a(VCFParser::Variation) }

        it { expect{ VCFParser.parse(text) }.to output.to_stderr }
      end
    end
  end
end