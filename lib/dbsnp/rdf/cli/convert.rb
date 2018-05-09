require 'optparse'
require 'rdf'

module DbSNP
  module RDF
    module CLI
      class Convert

        DEFAULT_OPTIONS = {
            dst:  ENV['DATA_DIR'] || ENV['PWD'],
            help: false
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
            end
            op.on('-s', '--slice [SIZE]',
                  'size of each slice in parallel processing of variations (default: 10000)') do |slice|
              @options[:slice] = slice.to_i
            end

            op.on('-p', '--process [NUMBER]',
                  'number of processes to use (default: 1)') do |number|
              @options[:process] = number.to_i
            end

            op.on('-r', '--raptor',
                  'use Raptor serializer instead of the pure ruby serializer',
                  'NOTE: make sure that Raptor is installed on your system') do |number|
              @options[:raptor] = true
            end

            op.separator('')
          end
        end

        def validate_arguments
          raise OptionParser::InvalidArgument.new("--process must be positive integer") if @options[:process] && @options[:process] <= 0
          raise OptionParser::InvalidArgument.new("--slice must be positive integer") if @options[:slice] && @options[:slice] <= 0

          raise OptionParser::InvalidArgument.new("src and dst must be specified") if ARGV.size < 2
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
