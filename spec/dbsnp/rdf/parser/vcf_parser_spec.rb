
require 'spec_helper'


module Dbsnp::Rdf::Parser
  RSpec.describe VcfParser do
    it { expect(VcfParser).to respond_to(:parse_line) }

    describe '#parse' do
      let(:subject) { VcfParser.parse_line(text) }
      context 'for rs775809821' do
        let(:text) { "1\t10019\trs775809821\tTA\tT\t.\t.\tRS=775809821;RSPOS=10020;dbSNPBuildID=144;SSR=0;SAO=0;VP=0x050000020005000002000200;GENEINFO=DDX11L1:100287102;WGT=1;VC=DIV;R5;ASP" }

        it { is_expected.to be_a(VcfParser::Refsnp) }

        it 'should parse one rs line' do
          expect(subject.id).to eq('rs775809821')
          expect(subject.ref).to eq('TA')
          expect(subject.alt).to eq('T')
        end
      end

      context 'for rs1052373574' do
        let(:text) { "1\t10051\trs1052373574\tA\tG\t.\t.\tRS=1052373574;RSPOS=10051;dbSNPBuildID=150;SSR=0;SAO=0;VP=0x050000020005000002000100;GENEINFO=DDX11L1:100287102;WGT=1;VC=SNV;R5;ASP" }

        it { is_expected.to be_a(VcfParser::Refsnp) }

        it 'should parse one rs line' do
          expect(subject.id).to eq('rs1052373574')
          expect(subject.ref).to eq('A')
          expect(subject.alt).to eq('G')
        end
      end

      context 'for rs62651026' do
        let(:text) { "1\t10108\trs62651026\tC\tT\t.\t.\tRS=62651026;RSPOS=10108;dbSNPBuildID=129;SSR=0;SAO=0;VP=0x050000020005000002000100;GENEINFO=DDX11L1:100287102;WGT=1;VC=SNV;R5;ASP" }

        it { is_expected.to be_a(VcfParser::Refsnp) }

        it 'should parse one rs line' do
          expect(subject.id).to eq('rs62651026')
          expect(subject.ref).to eq('C')
          expect(subject.alt).to eq('T')
        end
      end

      context 'for empty line' do
        let(:text) { '' }

        it { is_expected.to be_nil }
      end

      context 'for commented line' do
        let(:text) { "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO" }

        it { is_expected.to be_nil }
      end

      context 'for line with too many columns' do
        let(:text) { "1\t10019\trs775809821\tTA\tT\t.\t.\tRS=775809821;RSPOS=10020;dbSNPBuildID=144;SSR=0;SAO=0;VP=0x050000020005000002000200;GENEINFO=DDX11L1:100287102;WGT=1;VC=DIV;R5;ASP\tredundant\tcolumn" }

        it { expect { subject }.to raise_exception(VcfParser::FormatError) }
      end

      context 'for line with too few columns' do
        let(:text) { "1\t10019\trs775809821\tTA\tT\t.\t." }

        it { expect { subject }.to raise_exception(VcfParser::FormatError) }
      end
    end
  end
end
