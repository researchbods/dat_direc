# frozen_string_literal: true

require "dat_direc/core/database"
require "dat_direc/core/table"
require "dat_direc/dump_parsers/mysql/column"
require "dat_direc/dump_parsers/mysql/key"

module DatDirec
  module DumpParsers
    class MySQL
      def self.detect(io)
        res = io.gets =~ /MySQL/
        io.rewind
        res
      end

      def initialize(io)
        @io = io
        @table = nil
      end

      def parse
        @database = Database.new(:mysql)
        @io.each.with_index do |line, index|
          @line_no = index + 1
          parse_line(line)
        end
        @database
      end

      COLUMNS_REGEXP = /^\s*`([^`]*)`/.freeze

      def parse_line(line)
        case line.strip
        when /^CREATE TABLE `(.*)`/
          @table = Table.new(Regexp.last_match[1])
        when COLUMNS_REGEXP
          col = parse_column(line.strip)
          @table.add_column(col)
        when /^(PRIMARY |UNIQUE )?KEY/
          key = parse_key(line.strip)
          @table.indexes << key
        when /^\).*;$/
          @database.add_table(@table)
          @table = nil
        end
      end

      def parse_key(line)
        Key.new(line, @line_no).parse
      end

      def parse_column(line)
        Column.new(line, @line_no).parse
      end
    end
  end
end
