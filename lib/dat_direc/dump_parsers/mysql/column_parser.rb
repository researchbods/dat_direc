# frozen_string_literal: true

require "dat_direc/dump_parsers/parse_helper"
require "dat_direc/dump_parsers/mysql/column_options_parser"
require "dat_direc/core/column"

module DatDirec
  module DumpParsers
    class MySQL
      # Parser for MySQL columns inside a CREATE TABLE, one column per line
      class ColumnParser
        TYPE_MAP = {
          "varchar" => "string",
          "char" => "string",
        }.freeze

        def self.generic_type(type)
          TYPE_MAP[type] || type
        end

        include ParseHelper

        def initialize(line, line_no)
          @pos = 0
          @io = StringIO.new(line)
          @line_no = line_no
        end

        def parse
          parse_name
          parse_type
          parse_options
          debug options.inspect

          ::DatDirec::Column.new(@name, generic_type, options)
        end

        def options
          @options ||= {}
        end

        def parse_name
          @name = read_delimited_string
          getc(" ")
        end

        TYPE_REGEX = /^([a-zA-Z]+)(?:\((\d+)(?:,(\d+))?\))?$/.freeze

        def parse_type
          debug "parsing type"

          type = read_to_next(" ")
          raise "'#{type}' did not match the regex" unless type =~ TYPE_REGEX

          type, limit, decimal = Regexp.last_match[1..3]

          @type = type
          options[:limit] = Integer(limit) if limit
          options[:decimal] = Integer(decimal) if decimal
        end

        def parse_options
          options.merge!(ColumnOptionsParser.new(@io).parse)
        end

        def generic_type
          self.class.generic_type @type
        end
      end
    end
  end
end
