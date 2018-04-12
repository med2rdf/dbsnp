require 'spec_helper'


module Dbsnp::Rdf::Parser
  RSpec.describe EntryParser do
    it { expect(EntryParser.new('text')).to respond_to(:parse) }


    describe '#parse' do
      let(:subject) { EntryParser.new(text).parse }
      context 'for examples/rs171.txt' do
        let(:text) { File.open(File.join(Dbsnp::Rdf::ROOT_DIR, 'spec', 'examples', 'rs171.txt')).read }

        it { is_expected.to be_a(EntryParser::Refsnp) }

        it 'should parse one rs line' do
          expect(subject.rs.count).to eq(1)
          rs = subject.rs[0]
          expect(rs.rs_id).to eq('rs171')
          expect(rs.taxonomy_id).to eq('9606')
          expect(rs.snp_class).to eq('snp')
        end

        it 'should parse one SNP line' do
          expect(subject.snp.count).to eq(1)
          snp = subject.snp[0]
          expect(snp.alleles).to eq('A/G')
        end

        it 'should parse one CTG line' do
          expect(subject.ctg.count).to eq(1)
          ctg = subject.ctg[0]
          expect(ctg.group_label).to eq('GRCh38.p7')
          expect(ctg.chromosome).to eq('1')
          expect(ctg.loctype).to eq('2')
        end

        it { expect(subject.loc.count).to eq(0) }

        it { expect(subject.gmaf.count).to eq(0) }

        it { expect(subject.clinsig.count).to eq(0) }
      end

      context 'for examples/rs171.txt' do
        let(:text) { File.open(File.join(Dbsnp::Rdf::ROOT_DIR, 'spec', 'examples', 'rs242.txt')).read }

        it { is_expected.to be_a(EntryParser::Refsnp) }

        it 'should parse one rs line' do
          expect(subject.rs.count).to eq(1)
          rs = subject.rs[0]
          expect(rs.rs_id).to eq('rs242')
          expect(rs.taxonomy_id).to eq('9606')
          expect(rs.snp_class).to eq('in-del')
        end

        it 'should parse one SNP line' do
          expect(subject.snp.count).to eq(1)
          snp = subject.snp[0]
          expect(snp.alleles).to eq('-/T')
        end

        it 'should parse one CTG line' do
          expect(subject.ctg.count).to eq(1)
          ctg = subject.ctg[0]
          expect(ctg.group_label).to eq('GRCh38.p7')
          expect(ctg.chromosome).to eq('1')
          expect(ctg.loctype).to eq('1')
        end

        it { expect(subject.loc.count).to eq(0) }

        it 'should parse one GMAF line' do
          expect(subject.gmaf.count).to eq(1)
          gmaf = subject.gmaf[0]
          expect(gmaf.allele).to eq('-')
          expect(gmaf.sample_size).to eq('5008')
          expect(gmaf.freq).to eq('0.0513179')
        end

        it { expect(subject.clinsig.count).to eq(0) }

      end

      context 'for examples/rs665.txt' do
        let(:text) { File.open(File.join(Dbsnp::Rdf::ROOT_DIR, 'spec', 'examples', 'rs665.txt')).read }

        it { is_expected.to be_a(EntryParser::Refsnp) }

        it 'should parse one rs line' do
          expect(subject.rs.count).to eq(1)
          rs = subject.rs[0]
          expect(rs.rs_id).to eq('rs665')
          expect(rs.taxonomy_id).to eq('9606')
          expect(rs.snp_class).to eq('snp')
        end

        it 'should parse one SNP line' do
          expect(subject.snp.count).to eq(1)
          snp = subject.snp[0]
          expect(snp.alleles).to eq('A/G')
        end

        it 'should parse one CTG line' do
          expect(subject.ctg.count).to eq(1)
          ctg = subject.ctg[0]
          expect(ctg.group_label).to eq('GRCh38.p7')
          expect(ctg.chromosome).to eq('1')
          expect(ctg.loctype).to eq('2')
        end

        it 'should parse eight LOC line' do
          expect(subject.loc.count).to eq(8)
          expect(subject.loc.map(&:locus_id)).to all(eq('2517'))
          expect(subject.loc.select { |s| s.functional_class == 'missense' }.count).to eq(4)
          expect(subject.loc.select { |s| s.functional_class == 'reference' }.count).to eq(4)
        end

        it 'should parse one GMAF line' do
          expect(subject.gmaf.count).to eq(1)
          gmaf = subject.gmaf[0]
          expect(gmaf.allele).to eq('T')
          expect(gmaf.sample_size).to eq('5008')
          expect(gmaf.freq).to eq('0.000998403')
        end

        it 'should parse one CLINSIG line' do
          expect(subject.clinsig.count).to eq(1)
          expect(subject.clinsig[0].assertion).to eq('Likely benign')
        end
      end

      context 'for invalid header' do
        let(:text) { "INVALID | alleles='A/G' | het=0 | se(het)=0" }
        it { expect { subject }.to raise_error(EntryParser::FormatError) }
      end

      context 'for invalid rs' do
        let(:text) { 'rs171 | human | INVALID_TAX_ID | snp | genotype=YES | submitterlink=YES | updated 2016-10-18 16:48' }
        it { expect { subject }.to raise_error(EntryParser::FormatError) }
      end

      context 'for invalid SNP' do
        let(:text) { "SNP | alleles='INVALID/INVALID' | het=0 | se(het)=0" }
        it { expect { subject }.to raise_error(EntryParser::FormatError) }
      end

      context 'for invalid CTG' do
        let(:text) { 'CTG | assembly_INVALID=GRCh38.p7 | chr=1 | chr-pos=175292543 | NT_004487.20 | ctg-start=32107956 | ctg-end=32107956 | loctype=2 | orient=-' }
        it { expect { subject }.to raise_error(EntryParser::FormatError) }
      end

      context 'for invalid GMAF' do
        let(:text) { 'GMAF | allele=T | count=INVALID | MAF=0.000998403' }
        it { expect { subject }.to raise_error(EntryParser::FormatError) }
      end

      context 'for invalid LOC' do
        let(:text) { 'LOC | FUCA1 | locus_id=INVALID | fxn-class=missense | allele=A | frame=1 | residue=I | aa_position=260 | mrna_acc=NM_000147.4 | prot_acc=NP_000138.2
' }
        it { expect { subject }.to raise_error(EntryParser::FormatError) }
      end

      context 'for invalid CLINSIG' do
        let(:text) { 'CLINSIG | INVALID=Likely benign' }
        it { expect { subject }.to raise_error(EntryParser::FormatError) }
      end
    end
  end
end
