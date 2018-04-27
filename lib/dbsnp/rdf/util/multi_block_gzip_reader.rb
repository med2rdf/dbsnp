require 'zlib'

module DbSNP::RDF::Util
  class MultiBlockGzipReader
    def initialize(file)
      @io = file
    end

    def each_line(&block)
      unused_size = 0
      remaining_line = ''
      until @io.eof?
        Zlib::GzipReader.wrap(@io) do |gz|
          gz.each_line do |line|
            if line.end_with?("\n")
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
    end
    #TODO: implement other interfaces
  end
end
