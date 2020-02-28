# frozen_string_literal: true

require "dat_direc/dump_parsers/parse_helper"
require "dat_direc/core/column"

module DatDirec
  module DumpParsers
    class MySQL
      # Parser for MySQL columns inside a CREATE TABLE, one column per line
      class Column
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

          type = Regexp.last_match[1]
          limit = Regexp.last_match[2]
          decimal = Regexp.last_match[3]

          @type = type
          options[:limit] = Integer(limit) if limit
          options[:decimal] = Integer(decimal) if decimal
        end

        def parse_options
          words = @io.read.chomp.chomp(",").split(" ")
          debug "words starts as #{words}"
          words = parse_collate(words) unless words.empty?
          words = parse_null(words) unless words.empty?
          words = parse_default(words) unless words.empty?
          words = parse_auto_increment(words) unless words.empty?

          debug "Unsupported extra bits: #{words.join(' ')}" unless words.empty?
        end

        def parse_collate(words)
          debug "parse_collate '#{words.join("', '")}'"
          if words[0]&.upcase == "COLLATE"
            debug "collate!"
            options[:collate] = words[1]
            words.slice(2, words.count)
          else
            words
          end
        end

        def parse_null(words)
          debug "parse_null '#{words.join("', '")}'"
          if words[0]&.upcase == "NOT" && words[1]&.upcase == "NULL"
            options[:null] = false
            words.slice(2, words.count)
          elsif words[0]&.upcase == "NULL"
            options[:null] = true
            words.slice(1, words.count)
          else
            words
          end
        end

        def parse_default(words)
          debug "parse_default '#{words.join("', '")}'"
          if words[0]&.upcase == "DEFAULT"
            if words[1]&.upcase == "NULL"
              options[:default] = nil
              words.slice(2, words.count)
            else
              chrs = StringIO.new(words.slice(1, words.count).join(" "))
              getc("'", io: chrs)
              options[:default] = read_to_next("'", io: chrs)
              chrs.read.split(" ")
            end
          else
            words
          end
        end

        def parse_auto_increment(words)
          debug "parse_auto_increment '#{words.join("', '")}'"
          if words[0]&.upcase == "AUTO_INCREMENT"
            options[:auto_increment] = true
            words.slice(1, words.count)
          else words
          end
        end

        def generic_type
          self.class.generic_type @type
        end
      end
    end
  end
end
