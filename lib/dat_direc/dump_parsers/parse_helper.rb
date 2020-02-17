module DatDirec
  module DumpParsers
    # base s with some shared functionality for parsing simple stuff
    module ParseHelper
      def read_delimited_string(delimiter: "`", io: @io)
        getc(delimiter, io: io)
        read_to_next(delimiter, io: io)
      end

      def read_key
        key = read_to_next(" ")
        error! "Unexpected '#{key}' - expecting KEY" if key != "KEY"
      end

      def getc(*expected, io: @io)
        @last_read_pos = io.pos
        chr = io.getc
        expected = expected.flatten.compact
        if !expected.empty? && !expected.include?(chr)
          error! "Unexpected '#{chr}', expected '#{expected.join("' or '")}'"
        end
        chr
      end

      def read_to_next(sep, keep: false, io: @io)
        @last_read_pos = io.pos
        str = io.gets(sep)
        if keep
          str
        else
          str.chomp(sep)
        end
      end

      def debug(msg)
        puts msg if ENV["DAT_DIREC_DEBUG"]
      end

      def error!(message, pos: @last_read_pos)
        raise "line #{@line_no}, char #{pos}: #{message}"
      end
    end
  end
end
