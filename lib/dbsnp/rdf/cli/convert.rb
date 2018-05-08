require 'optparse'
require 'rdf'

module DbSNP
  module RDF
    module CLI
      class Convert

        DEFAULT_OPTIONS = {
            output_dir: ENV['DATA_DIR'] || ENV['PWD'],
            help:   false,
            verbose: false
        }.freeze

        def initialize
          @options = DEFAULT_OPTIONS.dup
        end

        def run
          option_parser.parse!

          if @options[:help]
            STDERR.puts option_parser.help
            exit 0
          end

          validate_arguments

          Generator::TurtleGenerator.new(ARGV[0], ARGV[1], @options).all

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
            op.banner = "Usage: #{CLI::PROG_NAME} #{self.class.name.demodulize.underscore} <src> <dst>\n"
            op.banner += "Convert dbSNP data to RDF\n"

            op.separator("\nOptions:")
            op.on('-h', '--help', 'show help') do
              @options[:help] = true
              puts 'help'
            end
            op.on('-v', '--verbose [INTERVAL]', OptionParser::DecimalInteger,
                  'show count of parsed variation lines in progress',
                  'The output interval can be specified as an integer (equals 100 by default).') do |itv|
              @options[:verbose] = itv || 100
            end
            op.separator('')
          end
        end

        def validate_arguments
          verbose = @options[:verbose]
          raise OptionParser::InvalidOption.new("INTERVAL of verbose must be positive integer") if verbose && verbose <= 0

          raise OptionParser::InvalidOption.new("src and dst must be specified") if ARGV.size < 2
          src, dst = ARGV
          raise OptionParser::InvalidArgument.new("#{src} must not be a directory.") if File.directory?(src)
          raise OptionParser::InvalidArgument.new("#{src} does not exist.") unless File.exist?(src)
          raise OptionParser::InvalidArgument.new("#{dst} does not exist.") unless File.exist?(dst)
          raise OptionParser::InvalidArgument.new("#{dst} must be a directory.") unless File.directory?(dst)
        end
      end
    end
  end
end
