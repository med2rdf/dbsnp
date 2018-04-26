require 'rspec'

module DbSNP::RDF::Generator
  RSpec.describe 'TurtleGenerator' do
    it { expect(TurtleGenerator).to respond_to(:new).with(2).arguments }

    it { expect(TurtleGenerator.new('src_path', 'dst_path')).to respond_to(:all).with(0).arguments }

    it { expect(TurtleGenerator.new('src_path', 'dst_path')).to respond_to(:ontology).with(0).arguments }

    it { expect(TurtleGenerator.new('src_path', 'dst_path')).to respond_to(:refsnps).with(0).arguments }

    let(:sample_src) { File.join('spec', 'examples', 'vcf', 'three_snps.vcf')}

    let(:sample_dst) { File.join('spec', 'tmp')}

    let(:subject) { TurtleGenerator.new(sample_src, sample_dst) }

    describe '#all' do
      it 'should call ontology and refsnps' do
        expect(subject).to receive(:ontology)
        expect(subject).to receive(:refsnps)

        subject.all
      end
    end

    describe '#ontology' do
      let(:dst_ttl) { File.join(sample_dst, 'dbsnp.ttl') }

      before do
        File.delete(dst_ttl) if File.exists?(dst_ttl)
      end

      it 'should output a file' do
        subject.ontology

        expect(File.exists?(dst_ttl)).to eq(true)
      end
    end

    describe '#refsnps' do
      let(:dst_ttl) { File.join(sample_dst, 'refsnps.ttl') }

      before do
        File.delete(dst_ttl) if File.exists?(dst_ttl)
      end

      it 'should output a file' do
        subject.refsnps

        expect(File.exists?(dst_ttl)).to eq(true)
      end
    end
  end
end