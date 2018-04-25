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
          refsnp = subject.first
          expect(refsnp.id).to eq('rs775809821')
          expect(refsnp.variation_class).to eq('INDEL')
          expect(refsnp.gene_id).to eq(nil)
          expect(refsnp.reference_allele).to eq('TA')
          expect(refsnp.alternative_alleles).to eq(%w[T])
          expect(refsnp.frequency).to eq(nil)
          expect(refsnp.reference_sequence).to eq('NC_000001.10')
          expect(refsnp.position).to eq('10019')
          expect(refsnp.clinical_significance).to eq(nil)
        end
      end


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