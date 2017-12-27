require 'nokogiri'

module Dbsnp
  module RDF
    module Parser
      class DbsnpXML
        def self.open(path, options)
          f = case path
              when /\.gz$/
                Zlib::GzipReader.open(path)
              else
                File.open(path)
              end

          begin
            rs = new(f, options)
          rescue StandardError
            f.close
            raise
          end

          if block_given?
            begin
              yield rs
            ensure
              rs.close
            end
          else
            rs
          end
        end

        def self.foreach(path, options = {}, &block)
          return to_enum(__method__, path, options) unless block
          open(path, options) do |rs|
            rs.each(&block)
          end
        end

        def initialize(data, options)
          @io = data.respond_to?(:read) && data.respond_to?(:close) ? data : StringIO(data)

          @find_existing_entry = options[:find_existing_entry]
        end

        extend Forwardable
        def_delegators :@io, :binmode, :binmode?, :close, :close_read, :close_write,
                       :closed?, :eof, :eof?, :external_encoding, :fcntl,
                       :fileno, :flock, :flush, :fsync, :internal_encoding,
                       :ioctl, :isatty, :path, :pid, :pos, :pos=, :reopen,
                       :seek, :stat, :string, :sync, :sync=, :tell, :to_i,
                       :to_io, :truncate, :tty?

        def parse(&block)
          Nokogiri::XML::SAX::Parser.new(Dbsnp::RDF::XML::Dbsnp.new(@find_existing_entry, &block)).parse(@io)
        end

        def each(&block)
          parse(&block)
        end
      end
    end
  end
end
