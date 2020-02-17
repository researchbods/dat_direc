# frozen_string_literal: true

require "dat_direc/dump_parsers/parse_helper"
require "dat_direc/core/index"

module DatDirec
  module DumpParsers
    class MySQL
      # Parses a single KEY line
      class Key
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
          @options ||= {}
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
          carry_on = true
          while carry_on
            @columns << read_delimited_string

            case getc(")", ",")
            when ","
              next
            when ")"
              carry_on = false
            end
          end
        end
      end
    end
  end
end
