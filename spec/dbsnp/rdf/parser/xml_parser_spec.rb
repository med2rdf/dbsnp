require 'spec_helper'


module DbSNP::RDF::Parser
  RSpec.describe XmlParser do
    it { expect(XmlParser.new('text')).to respond_to(:each) }

    describe '#parse' do
      let(:subject) { XmlParser.open(text) }
      context 'for 171_242_538.xml' do
        let(:text) { File.join(DbSNP::RDF::ROOT_DIR, 'spec', 'examples', 'xml', '171_242_538.xml') }

        it { is_expected.to be_a(XmlParser) }

        it 'should parse three entries' do
          rs171, rs242, rs538 = subject.first(3)

          expect(rs171).to be_a(XmlParser::Refsnp)
          expect(rs171.id).to eq('171')
          expect(rs171.snp_type).to eq('snp')
          expect(rs171.gene_id).to be_nil
          expect(rs171.frequency).to be_nil
          expect(rs171.sample_size).to be_nil
          expect(rs171.clinical_significance).to be_nil
          expect(rs171.hgvs.count).to eq(2)
          expect(rs171.hgvs).to include('NC_000001.10:g.175261679T>C')
          expect(rs171.hgvs).to include('NC_000001.11:g.175292543T>C')

          expect(rs242).to be_a(XmlParser::Refsnp)
          expect(rs242.id).to eq('242')
          expect(rs242.snp_type).to eq('in-del')
          expect(rs242.gene_id).to be_nil
          expect(rs242.frequency).to eq('0.0513')
          expect(rs242.sample_size).to eq('5008')
          expect(rs242.clinical_significance).to be_nil
          expect(rs171.hgvs.count).to eq(2)
          expect(rs242.hgvs).to include('NC_000001.10:g.20869461delT')
          expect(rs242.hgvs).to include('NC_000001.11:g.20542968delT')

          expect(rs538).to be_a(XmlParser::Refsnp)
          expect(rs538.id).to eq('538')
          expect(rs538.snp_type).to eq('snp')
          expect(rs538.gene_id).to eq('8514')
          expect(rs538.frequency).to eq('0.2091')
          expect(rs538.sample_size).to eq('5008')
          expect(rs538.clinical_significance).to be_nil
          expect(rs538.hgvs.count).to eq(30)
          expect(rs538.hgvs).to include('NC_000001.10:g.6160958A>C')
          expect(rs538.hgvs).to include('NC_000001.10:g.6160958A>G')
          expect(rs538.hgvs).to include('NC_000001.11:g.6100898A>C')
          expect(rs538.hgvs).to include('NC_000001.11:g.6100898A>G')
        end
      end

      context 'for 665.xml' do
        let(:text) { File.join(DbSNP::RDF::ROOT_DIR, 'spec', 'examples', 'xml', '665.xml') }

        it { is_expected.to be_a(XmlParser) }

        it 'should parse three entries' do
          rs665 = subject.first

          expect(rs665).to be_a(XmlParser::Refsnp)
          expect(rs665.id).to eq('665')
          expect(rs665.snp_type).to eq('snp')
          expect(rs665.gene_id).to eq('2517')
          expect(rs665.frequency).to eq('0.001')
          expect(rs665.sample_size).to eq('5008')
          expect(rs665.clinical_significance).to eq('Likely benign')
          expect(rs665.hgvs.count).to eq(12)
          expect(rs665.hgvs).to include('NC_000001.10:g.24181041C>T')
          expect(rs665.hgvs).to include('NC_000001.11:g.23854551C>T')
        end
      end
    end
  end
end
