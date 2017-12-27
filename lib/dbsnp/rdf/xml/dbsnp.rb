require 'nokogiri'

module Dbsnp
  module RDF
    module XML
      class Dbsnp < Nokogiri::XML::SAX::Document
        def initialize(find_existing_entry = true, &block)
          @find_existing_entry = find_existing_entry
          @callback            = block

          @stack      = []
          @characters = ''

          @ref_allele = []
          @builds     = []
          @hgvs       = []

          @skip = false

          @logger = Importer.logger
        end

        def start_element(name, attributes = [])
          @stack.push name

          return if @skip

          @characters = ''
          attr        = attributes.to_h

          case name
          when 'Rs'
            @ref_allele  = []
            @builds      = []
            @hgvs        = []
            @report      = nil
            @found_entry = false

            # TODO: handle all classes
            @skip = (attr['snpClass'] != 'snp')

            if @find_existing_entry && (e = Models::Report.find_by(rs: attr['rsId'].to_i))
              puts 'found'
              @report      = e
              @found_entry = true
            end
            @report ||= Models::Report.new do |r|
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
            unless @found_entry
              @report.frequencies << Models::Frequency.new do |r|
                r[:frequency]   = attr['freq'].to_f
                r[:allele]      = attr['allele']
                r[:sample_size] = attr['sampleSize'].to_i
              end
            end
          end
        end

        def end_element(name, attributes = [])
          raise unless name == @stack.pop

          if @skip && name != 'Rs'
            return
          end

          case name
          when 'Rs'
            @skip = false

            unless @found_entry
              return unless check_cardinary
              @report.alleles.push(*make_alleles)
            end
            @report.builds.push(*@builds)

            @callback.call(@report)
          when 'Component'
            return unless @stack[-1] == 'Assembly'

            @builds << @build
          when 'hgvs'
            unless @found_entry
              @hgvs << @characters.strip
              @report.hgvs_names << Models::HgvsName.new do |r|
                r[:name] = @characters.strip
              end
            end
          when 'ClinicalSignificance'
            unless @found_entry
              @report.significances << Models::Significance.new do |r|
                r[:name] = @characters.strip
              end
            end
          end
        end

        def characters(value)
          return if @skip

          @characters << value
        end

        private

        def check_cardinary
          unless @ref_allele.uniq.size == 1
            if @logger
              @logger.warn("rs#{@report[:rs]}: reference allele must be one, but #{@ref_allele}")
            end
            return false
          end

          true
        end

        def make_alleles
          case @report[:snp_class]
          when 'snp'
            @hgvs.map { |s| (g = s.match('NC_[0-9\.]+:g\.\d+[ATGC]+>([ATGC]+)')) ? g[1] : nil }
              .compact
              .uniq
              .map do |alt|
              Models::Allele.new do |r|
                r[:ref] = @ref_allele[0]
                r[:alt] = alt
              end
            end
          else
            @logger.warn("rs#{@report[:rs]}: unknown/unhandleable SNP class '#{@report[:snp_class]}'")
            []
          end
        end
      end
    end
  end
end
