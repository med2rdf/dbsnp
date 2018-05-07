require 'zlib'

module DbSNP::RDF::Util
  class MultiBlockGzipReader
    extend Forwardable
    include Enumerable

    attr_reader :lineno

    def_delegators :@io, :binmode, :binmode?, :close, :close_read, :close_write,
                   :closed?, :eof, :eof?, :external_encoding, :fcntl,
                   :fileno, :flock, :flush, :fsync, :internal_encoding,
                   :ioctl, :isatty, :path, :pid, :pos, :pos=, :reopen,
                   :seek, :stat, :string, :sync, :sync=, :tell, :to_i,
                   :to_io, :truncate, :tty?


    def initialize(file)
      @io = file
      @lineno = 0
    end

    def each
      if block_given?
        unused_size = 0
        remaining_line = ''
        until @io.eof?
          Zlib::GzipReader.wrap(@io) do |gz|
            gz.each_line do |line|
              if line.end_with?("\n")
                @lineno += 1
                yield remaining_line + line
                remaining_line = ''
              else
                remaining_line += line
              end
            end
            unused_size = gz.unused ? gz.unused.size : 0
            gz.finish
          end
          @io.seek(-unused_size, IO::SEEK_CUR)
        end
      else
        to_enum
      end
    end

    alias each_line each
  end
end
