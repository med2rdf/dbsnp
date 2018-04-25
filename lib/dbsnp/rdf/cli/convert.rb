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

          writer = ::RDF::Writer.for(:turtle)

          File.open(ARGV[1], 'w') do |file|
            file.write(writer.buffer(prefixes: DbSNP::RDF::PREFIXES, stream: true) do |_|
              # just output header
            end)
            Parser::XmlParser.open(ARGV[0]).each do |refsnp|
              file.write(writer.buffer(prefixes: DbSNP::RDF::PREFIXES) do |buffer|
                DbSNP::RDF::Converter::RefsnpToTriples.convert(refsnp).each { |statement| buffer << statement }
              end.gsub(/^@.*$\n/, ''))
            end
          end

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
          raise("#{src} is a directory.") if File.directory?(src)
          raise("#{src} does not exist.") unless File.exist?(src)
          raise("#{dst} is a directory.") if File.directory?(dst)
        end
      end
    end
  end
end
