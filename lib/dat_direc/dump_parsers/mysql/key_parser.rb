# frozen_string_literal: true

require "dat_direc/dump_parsers/parse_helper"
require "dat_direc/core/index"

module DatDirec
  module DumpParsers
    class MySQL
      # Parses a single KEY line
      class KeyParser
        include ParseHelper

        def initialize(line, line_no)
          @pos = 0
          @io = StringIO.new(line)
          @line_no = line_no
        end

        def parse
          parse_type
          parse_name if @type != "primary"
          parse_columns

          Index.new(name: @name || "",
                    columns: @columns,
                    type: @type,
                    options: options)
        end

        private

        # I'm sure there'll be something
        def options
          @options ||= begin
                         opts = {}
                         opts[:length] = @column_lengths unless @column_lengths.empty?
                         opts
                       end
        end

        def parse_type
          type = read_to_next(" ")
          case type
          when "PRIMARY", "UNIQUE"
            @type = type.downcase
            read_key
          when "KEY"
            @type = "index"
          else
            error! "Unexpected '#{type}' - expecting PRIMARY, UNIQUE, or KEY"
          end
        end

        def parse_name
          @name = read_delimited_string
          read_to_next(" ")
        end

        def parse_columns
          getc("(")

          @columns = []
          @column_lengths = {}
          parse_column
        end

        def parse_column
          column = read_delimited_string

          @columns << column

          case getc("(", ")", ",")
          when "("
            @column_lengths[column] = Integer(read_to_next(")"))
            parse_column if getc(")", ",") == ","
          when ","
            parse_column
          end
        end

        def read_key
          key = read_to_next(" ")
          error! "Unexpected '#{key}' - expecting KEY" if key != "KEY"
        end

      end
    end
  end
end
