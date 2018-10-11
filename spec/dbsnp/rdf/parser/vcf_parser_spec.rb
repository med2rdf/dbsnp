require 'rspec'


module DbSNP::RDF::Parser
  RSpec.describe VCFParser do
    it { expect(VCFParser).to respond_to(:open).with(1).arguments }
    it { expect(VCFParser).to respond_to(:new).with(1).arguments }
    it { expect(VCFParser.new('text')).to respond_to(:each) }

    describe '#each' do
      let(:subject) { VCFParser.new(text).each }

      context 'for a line of rs775809821' do
        let(:text) { %w[NC_000001.10 10019 rs775809821 TA T . . RS=775809821;dbSNPBuildID=144;SSR=0;PSEUDOGENEINFO=DDX11L1:100287102;VC=INDEL].join("\t") }

        it { is_expected.to be_a(Enumerator) }

        it { expect(subject.to_a.count).to eq(1) }

        it 'should have properties of VCFParser::RefSNP' do
          variation = subject.first
          expect(variation.rs_id).to eq('rs775809821')
          expect(variation.variation_class).to eq('INDEL')
          expect(variation.gene_id).to eq(nil)
          expect(variation.reference_allele).to eq('TA')
          expect(variation.alternative_alleles).to eq(%w[T])
          expect(variation.frequency).to eq(nil)
          expect(variation.reference_sequence).to eq('NC_000001.10')
          expect(variation.position).to eq('10019')
          expect(variation.clinical_significance).to eq(nil)
        end
      end


      context 'for a line of rs537951473' do
        let(:text) { %w[NC_000001.10 13482 rs537951473 G A,C . . RS=537951473;dbSNPBuildID=142;SSR=0;PSEUDOGENEINFO=DDX11L1:100287102;VC=SNV;GNO;FREQ=1000Genomes:0.9996,.,0.0003994|ExAC:0.9998,.,0.0001704|GnomAD:1,.,0].join("\t") }

        it { is_expected.to be_a(Enumerator) }

        it { expect(subject.to_a.count).to eq(1) }

        it 'should have properties of VCFParser::RefSNP' do
          variation = subject.first
          expect(variation.rs_id).to eq('rs537951473')
          expect(variation.variation_class).to eq('SNV')
          expect(variation.gene_id).to eq(nil)
          expect(variation.reference_allele).to eq('G')
          expect(variation.alternative_alleles).to eq(%w[A C])
          expect(variation.frequency).to eq(['0.9996', nil, '0.0003994'])
          expect(variation.reference_sequence).to eq('NC_000001.10')
          expect(variation.position).to eq('13482')
          expect(variation.clinical_significance).to eq(nil)
        end
      end

      # TODO: clinical_significance
      # NC_000001.10	63738	rs869033224	ACT	CTA	.	.	RS=869033224;dbSNPBuildID=147;SSR=0;VC=MNV


      context 'for comment lines' do
        let(:text) { "#these \n# are \n# comments\n" }

        it { is_expected.to be_a(Enumerator) }

        it { expect(subject.to_a.count).to eq(0) }
      end
    end

    describe '#open' do
      let(:subject) { VCFParser.open(file) }
    end
  end
end