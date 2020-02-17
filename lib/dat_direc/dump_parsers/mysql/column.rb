require "dat_direc/dump_parsers/parse_helper"
require "dat_direc/core/column"

module DatDirec
  module DumpParsers
    class MySQL
      # Parser for MySQL columns inside a CREATE TABLE, one column per line
      class Column
        include ParseHelper
        def initialize(line, line_no)
          @pos = 0
          @io = StringIO.new(line)
          @line_no = line_no
        end

        def parse
          parse_name
          parse_type
          parse_options if getc == " "
          debug options.inspect

          ::DatDirec::Column.new(@name, @type, options)
        end

        def options
          @options ||= {}
        end

        def parse_name
          @name = read_delimited_string
          getc(" ")
        end

        def parse_type
          read_limit = false
          reading = true
          type = "".dup
          debug "parsing type"

          while reading
            chr = @io.getc
            debug "chr: '#{chr}'"
            case chr
            when "("
              read_limit = true
              reading = false
            when " ", ","
              reading = false
            else
              type << chr
            end
          end

          @type = type
          options[:limit] = Integer(read_to_next(")")) if read_limit
        end

        def parse_options
          words = @io.read.chomp.chomp(",").split(" ")
          words = parse_collate(words) unless words.empty?
          debug "options is now: #{options.inspect}"
          words = parse_null(words) unless words.empty?
          debug "options is now: #{options.inspect}"
          words = parse_default(words) unless words.empty?
          debug "options is now: #{options.inspect}"
          words = parse_auto_increment(words) unless words.empty?
          debug "options is now: #{options.inspect}"

          unless words.empty?
            debug "Unsupported extra bits: #{words.join(" ")}"
          end
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
              chrs.read.split(' ')
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
      end
    end
  end
end
