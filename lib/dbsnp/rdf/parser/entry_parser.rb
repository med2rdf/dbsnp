module Dbsnp::Rdf::Parser
  class EntryParser

    DELIMITER = '|'.freeze

    Refsnp = Struct.new(:rs, :snp, :gmaf, :ctg, :loc, :clinsig) do
      def initialize
        members.each { |m| send("#{m}=", []) }
      end
    end

    Rs = Struct.new(:rs_id, :taxonomy_id, :snp_class)

    Snp = Struct.new(:alleles)

    Ctg = Struct.new(:group_label, :chromosome, :loctype)

    Gmaf = Struct.new(:allele, :sample_size, :freq)

    Loc = Struct.new(:locus_id, :functional_class)

    Clinsig = Struct.new(:assertion)

    class FormatError < StandardError
      def initialize(line)
        super("Invalid Format: #{line}")
      end
    end


    def initialize(text)
      @text = text
    end

    def parse
      refsnp = Refsnp.new
      @text.each_line do |line|
        tokens = line.split(DELIMITER).map(&:strip)
        case tokens[0]
        when /^rs/
          rs             = Rs.new
          rs.rs_id       = tokens[0]
          rs.taxonomy_id = tokens[2].match(/\d+/) { |m| m[0] }
          rs.snp_class   = tokens[3]
          raise FormatError.new(line) if rs.any?(&:nil?)
          refsnp.rs << Rs.new(tokens[0], tokens[2], tokens[3])
        when /^SNP/
          if (match = tokens[1].match(/^alleles='([\-ATCG]\/[\-ATCG])'$/))
            refsnp.snp << Snp.new(match[1])
          else
            raise FormatError.new(line)
          end
        when /^CTG/
          ctg             = Ctg.new
          ctg.group_label = tokens[1].match(/^assembly=(.+)$/) { |m| m[1] }
          ctg.chromosome  = tokens[2].match(/^chr=(\d+)$/) { |m| m[1] }
          ctg.loctype     = tokens[7].match(/^loctype=(\d+)$/) { |m| m[1] }
          raise FormatError.new(line) if ctg.any?(&:nil?)
          refsnp.ctg << ctg
        when /^GMAF/
          gmaf             = Gmaf.new
          gmaf.allele      = tokens[1].match(/^allele=([\-ATCG])$/) { |m| m[1] }
          gmaf.sample_size = tokens[2].match(/^count=(\d+)$/) { |m| m[1] }
          gmaf.freq        = tokens[3].match(/^MAF=(\d+\.\d+)$/) { |m| m[1] }
          raise FormatError.new(line) if gmaf.any?(&:nil?)
          refsnp.gmaf << gmaf
        when /^LOC/
          loc                  = Loc.new
          loc.locus_id         = tokens[2].match(/^locus_id=(\d+)$/) { |m| m[1] }
          loc.functional_class = tokens[3].match(/^fxn-class=(.+)$/) { |m| m[1] }
          raise FormatError.new(line) if loc.any?(&:nil?)
          refsnp.loc << loc
        when /^CLINSIG/
          clinsig           = Clinsig.new
          clinsig.assertion = tokens[1].match(/^assertion=(.+)$/) { |m| m[1] }
          raise FormatError.new(line) if clinsig.any?(&:nil?)
          refsnp.clinsig << clinsig
        when /^ss/, /^VAL/, /^MAP/, /^GBL/, /^SEQ/
          # just ignore
        else
          raise FormatError.new(line)
        end

      end
      refsnp
    end
  end
end