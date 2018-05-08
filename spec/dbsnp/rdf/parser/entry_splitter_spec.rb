require 'rspec'

module DbSNP::RDF::Parser
  RSpec.describe EntrySplitter do
    it { expect(EntrySplitter).to respond_to(:open).with(1).arguments }
    it { expect(EntrySplitter).to respond_to(:new).with(1).arguments }
    it { expect(EntrySplitter.new('text')).to respond_to(:each) }

    describe '#each' do
      let(:subject) { EntrySplitter.new(text).each }
      context 'for comment lines' do
        let(:text) { "#these \n# are \n# comments\n" }

        it { is_expected.to be_a(Enumerator) }

        it { expect(subject.to_a.count).to eq(0) }
      end
    end

    describe '#open' do
      context 'for a raw vcf file' do
        let(:file) { File.join('spec', 'examples', 'vcf', 'three_snps.vcf') }
        let(:subject) { EntrySplitter.open(file) }

        it { is_expected.to be_a(EntrySplitter) }

        it 'should obtain three variations' do
          expect(subject.each.to_a.count).to eq(3)
        end
      end

      context 'for a gzipped vcf file' do
        let(:file) { File.join('spec', 'examples', 'vcf', '400_snps.vcf.gz') }
        let(:subject) { EntrySplitter.open(file) }

        it { is_expected.to be_a(EntrySplitter) }

        it 'should obtain 400 variations' do
          expect(subject.each.to_a.count).to eq(400)
        end
      end
    end
  end
end