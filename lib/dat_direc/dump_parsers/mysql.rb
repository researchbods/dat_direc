# frozen_string_literal: true

require "dat_direc/core/database"
require "dat_direc/core/table"
require "dat_direc/dump_parsers/mysql/column_parser"
require "dat_direc/dump_parsers/mysql/key_parser"
require "dat_direc/dump_parsers/registration"

module DatDirec
  module DumpParsers
    class MySQL
      def self.detect(io)
        res = io.gets&.downcase&.include?("mysql")
        io.rewind
        res
      end

      def self.name
        "MySQL"
      end

      def name
        self.class.name
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
          col = parse_column(line.strip.chomp(","))
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
        KeyParser.new(line, @line_no).parse
      end

      def parse_column(line)
        ColumnParser.new(line, @line_no).parse
      end
    end
  end
end

DatDirec::DumpParsers.register_parser(DatDirec::DumpParsers::MySQL)
