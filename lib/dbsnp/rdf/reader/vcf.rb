require 'active_model'
require 'active_support'
require 'active_support/core_ext/hash'

module DbSNP::RDF
  module Reader
    class FormatError < StandardError
    end

    class VCF
      COLUMN_DELIMITER = "\t".freeze
      MISSING_VALUE    = '.'.freeze

      class Info < Hash
        class << self
          # @param [String] str string at `INFO` column
          # @return [Hash] a hash that values are associated with column ID
          def parse(str)
            entries = str.split(';').map { |e| e.split('=', 2) }
            Hash[entries].symbolize_keys
          end
        end
      end

      class << self
        attr_accessor :assembly
        attr_accessor :latest_build

        def parse(line)
          tokens = line.split(COLUMN_DELIMITER).map(&:strip)

          raise FormatError, line unless tokens.length == 8

          begin
            DbSNP::RDF::Models::Variation.new do |v|
              v.chromosome          = tokens[0]
              v.assembly            = assembly
              v.latest_build        = Integer(latest_build)
              v.position            = Integer(tokens[1])
              v.rs                  = tokens[2]
              v.reference_allele    = tokens[3]
              v.alternative_alleles = tokens[4].split(',')

              info = Info.parse(tokens[7])

              if (x = info[:GENEINFO])
                v.gene_id_list = x.split('|').map { |y| Integer(y.split(':')[1]) }
              end

              v.first_build = Integer(info[:dbSNPBuildID])

              v.variation_class = info[:VC].presence

              if (x = info[:CLNACC])
                v.clinvar_accession = x.split(',').drop(1).map { |y| y == MISSING_VALUE ? nil : y }.map { |y| y.split('|') }
              end

              if (x = info[:FREQ])
                hash = x.split('|').map { |y| y.split(':') }.to_h
                hash.each do |k, v|
                  hash[k] = v.split(',').drop(1).map { |y| y == MISSING_VALUE ? nil : Float(y) }
                end
                v.frequency = hash
              end
            end
          rescue => e
            raise FormatError, ["#{e.message}: #{line}", e.backtrace].join("\n")
          end
        end
      end

      def initialize(io = STDIN)
        @io = io
      end

      def each
        line_no = 0
        if block_given?
          while (line = @io.gets&.chomp)
            line_no += 1
            unless line.start_with?('#')
              yield self.class.parse(line)
              break
            end
            process_header(line)
          end
          while (line = @io.gets&.chomp)
            line_no += 1
            begin
              yield self.class.parse(line)
            rescue ActiveModel::ValidationError => e
              @logger ||= Logger.new(STDERR)
              @logger.warn("Failed to convert data due to validation error at line #{line_no}: #{line}")
            end
          end
        else
          to_enum
        end
      end

      private

      def process_header(line)
        if (match = line.match(/##reference=([^.]+)/))
          self.class.assembly = match[1]
        end
        if (match = line.match(/##dbSNP_BUILD_ID=(\d+)/))
          self.class.latest_build = match[1]
        end
      end
    end
  end
end
