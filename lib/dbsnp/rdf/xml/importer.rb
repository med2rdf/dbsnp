module Dbsnp
  module RDF
    module XML
      class Importer
        # usage: Importer.new('***.xml').import

        attr_reader :path

        class << self
          attr_accessor :logger
        end

        def initialize(xml_path, find_existing_entry = true)
          @path                = xml_path
          @find_existing_entry = find_existing_entry
          @logger = Importer.logger
        end

        def import
          reports = []

          Parser::DbsnpXML.foreach(@path, find_existing_entry: @find_existing_entry, logger: @logger) do |report|
            begin
              reports << report if report && report.valid?
            rescue ActiveRecord::RecordInvalid => e
              if @logger
                @logger.warn("rs#{report}: #{e.message}") if report
              end
            end
          end

          Models::Report.import!(reports,
                                 recursive:               true,
                                 validate:                false,
                                 on_duplicate_key_update: [:id])
        end
      end
    end
  end
end
