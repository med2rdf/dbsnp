require 'rexml/parsers/pullparser'

module DbSNP::RDF::Parser
  class EntrySplitter
    extend Forwardable
    include Enumerable

    def_delegators :@io, :binmode, :binmode?, :close, :close_read, :close_write,
                   :closed?, :eof, :eof?, :external_encoding, :fcntl,
                   :fileno, :flock, :flush, :fsync, :internal_encoding,
                   :ioctl, :isatty, :path, :pid, :pos, :pos=, :reopen,
                   :seek, :stat, :string, :sync, :sync=, :tell, :to_i,
                   :to_io, :truncate, :tty?, :lineno

    def initialize(io)
      @file_path = io.is_a?(File) ? io.path : 'StringIO'
      @io = io.is_a?(String) ? StringIO.new(io) : io
    end

    def self.open(target)
      f = File.open(target)
      f = DbSNP::RDF::Util::MultiBlockGzipReader.new(f) if target.match?(/(\.bgz)|(\.gz)$/)
      begin
        splitter = new(f)
      rescue StandardError
        f.close
        raise
      end

      if block_given?
        begin
          yield splitter
        ensure
          splitter.close
        end
      else
        splitter
      end
    end

    def each
      if block_given?
        @io.each_line do |line|
          yield line unless line.start_with?('#')
        end
      else
        to_enum
      end
    end
  end
end