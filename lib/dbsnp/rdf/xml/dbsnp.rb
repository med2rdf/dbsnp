require 'nokogiri'

module Dbsnp
  module RDF
    module XML
      class Dbsnp < Nokogiri::XML::SAX::Document
        def initialize(&block)
          @callback = block

          @stack      = []
          @characters = ''

          @ref_allele  = []
          @builds      = []

          @skip = false
        end

        def start_element(name, attributes = [])
          @stack.push name

          return if @skip

          @characters = ''
          attr = attributes.to_h

          case name
          when 'Rs'
            @ref_allele = []

            # TODO: handle all classes
            @skip = attr['snpClass'] != 'snp'

            @report = Models::Report.new do |r|
              r[:rs]        = attr['rsId'].to_i
              r[:snp_class] = attr['snpClass']
              r[:snp_type]  = attr['snpType']
              r[:mol_type]  = attr['molType']
              r[:tax]       = attr['taxId'].to_i
            end
          when 'Component'
            return unless @stack[-2] == 'Assembly'

            @build = Models::Build.new do |r|
              r[:chr]    = attr['chromosome']
              r[:refseq] = attr['groupTerm']
            end
          when 'MapLoc'
            if @stack[-2] == 'Component' && @stack[-3] == 'Assembly'
              @ref_allele << attr['refAllele']
              @build[:position] = attr['physMapInt'].to_i + 1
            end
          when 'Frequency'
            @report.frequencies << Models::Frequency.new do |r|
              r[:frequency]   = attr['freq'].to_f
              r[:allele]      = attr['allele']
              r[:sample_size] = attr['sampleSize'].to_i
            end
          end
        end

        def end_element(name, attributes = [])
          raise unless name == @stack.pop

          return if @skip && name != 'Rs'

          case name
          when 'Rs'
            if @skip
              @callback.call(nil)
            else
              check_cardinary

              @report.alleles = make_alleles
              @report.builds  = @builds

              @callback.call(@report)
            end

            @skip = false
          when 'Component'
            return unless @stack[-1] == 'Assembly'

            @builds << @build
          when 'hgvs'
            @report.hgvs_names << Models::HgvsName.new do |r|
              r[:name] = @characters.strip
            end
          when 'ClinicalSignificance'
            @report.significances << Models::Significance.new do |r|
              r[:name] = @characters.strip
            end
          end
        end

        def characters(value)
          return if @skip

          @characters << value
        end

        private

        def check_cardinary
          raise("rs#{@report[:rs]}: reference allele must be one, but #{@ref_allele}") unless @ref_allele.uniq.size == 1
        end

        def make_alleles
          case @report[:snp_class]
          when 'snp'
            @report.hgvs_names
              .map { |s| (g = s[:name].match('>([ATGC]+)')) ? g[1] : nil }
              .compact
              .uniq
              .map do |alt|
              Models::Allele.new do |r|
                r[:ref] = @ref_allele[0]
                r[:alt] = alt
              end
            end
          else
            raise("rs#{@report[:rs]}: unknown/unhandleable SNP class '#{@report[:snp_class]}'")
          end
        end
      end
    end
  end
end
