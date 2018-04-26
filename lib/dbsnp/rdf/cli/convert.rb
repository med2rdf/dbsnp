require 'optparse'
require 'rdf'
require 'rdf/turtle'

module DbSNP
  module RDF
    module CLI
      class Convert

        DEFAULT_OPTIONS = {
            output_dir: ENV['DATA_DIR'] || ENV['PWD'],
            help:   false
        }.freeze

        def initialize
          @options = DEFAULT_OPTIONS.dup
        end

        def run

          if @options[:help]
            STDERR.puts option_parser.help
            exit 0
          end

          validate_arguments

          Generator::TurtleGenerator.new(ARGV[0], ARGV[1]).all

        rescue OptionParser::InvalidOption => e
          STDERR.puts e.message
          STDERR.puts
          STDERR.puts option_parser.help
          exit 1
        rescue OptionParser::InvalidArgument => e
          STDERR.puts e.message
          exit 2
        rescue StandardError => e
          STDERR.puts e.message
          STDERR.puts e.backtrace
          exit 99
        end

        private

        def option_parser
          OptionParser.new do |op|
            op.banner = "Usage: #{CLI::PROG_NAME} #{self.class.name.underscore} <src> <dst>\n"
            op.banner = "Convert dbSNP data to RDF\n"

            op.separator("\nOptions:")
            op.on('-h', '--help', 'show help') do
              @options[:help] = true
            end
            op.separator('')
          end
        end

        def validate_arguments
          raise("src and dst must be specified") if ARGV.size < 2
          src, dst = ARGV
          raise("#{src} must not be a directory.") if File.directory?(src)
          raise("#{src} does not exist.") unless File.exist?(src)
          raise("#{dst} does not exist.") unless File.exist?(dst)
          raise("#{dst} must be a directory.") unless File.directory?(dst)
        end
      end
    end
  end
end
