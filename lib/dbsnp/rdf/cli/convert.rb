require 'optparse'

module Dbsnp
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
          option_parser.parse!

          if @options[:help]
            STDERR.puts option_parser.help
            exit 0
          end

          validate_options

          # TODO: implement

        rescue OptionParser::InvalidOption
          STDERR.puts option_parser.help
          exit 1
        rescue OptionParser::InvalidArgument
          STDERR.puts option_parser.help
          exit 2
        rescue StandardError => e
          STDERR.puts e.message
          STDERR.puts e.backtrace
          exit 99
        end

        private

        def option_parser
          OptionParser.new do |op|
            op.banner = "Usage: #{CLI::PROG_NAME} #{self.class.name.underscore}\n"
            op.banner = "Convert dbSNP data to RDF\n"

            op.separator("\nOptions:")
            op.on('-o', '--output DIRECTORY', 'the directory where converted data will be stored') do |v|
              @options[:output_dir] = v
            end
            op.on('-h', '--help', 'show help') do
              @options[:help] = true
            end
            op.separator('')
          end
        end

        def validate_options
          output_dir = @options[:output_dir]

          raise("Directory not found: #{output_dir}") unless File.exist?(output_dir)
          raise("#{output_dir} is not a directory.") unless File.directory?(output_dir)
          raise("#{output_dir} is not writable.") unless File.writable?(output_dir)
        end
      end
    end
  end
end
