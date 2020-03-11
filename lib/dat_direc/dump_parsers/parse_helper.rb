# frozen_string_literal: true

module DatDirec
  module DumpParsers
    # some shared functionality for parsing simple stuff in a
    # character-by-character fashion. I'm too lazy to figure out
    # writing a proper grammar for sql.
    module ParseHelper
      def read_delimited_string(delimiter: "`", io: @io)
        getc(delimiter, io: io)
        read_to_next(delimiter, io: io)
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
