require "dat_direc/dump_parsers/parse_helper"

module DatDirec
  module DumpParsers
    class MySQL
      # Parses column options (COLLATE, NULL, DEFAULT, AUTO_INCREMENT, etc.)
      # These are the only options I've had to deal with, other options are
      # available (CHARACTER SET for a start) - feel free to open an issue / PR,
      # since adding more options should be pretty easy.
      class ColumnOptionsParser
        include ParseHelper

        def initialize(io)
          @words = io.read.chomp.chomp(",").split(" ")
          @options = {}
        end

        attr_reader :options
        # ultimately some less-gross pattern matching may be in order
        # - some kind of hash-y structure like this
        # OPTIONS = {
        #   [ "COLLATE", :string ] => ->(arg){ options[:collation] = arg },
        #   [ "CHARACTER", "SET", :string ] => ->(arg) { options[:character_set] =
        #   arg },
        #   [ "NOT", "NULL" ] => -> { options[:null] = false },
        #   [ "NULL" ] => -> { options[:null] = true },
        #   [ "AUTO_INCREMENT" ] => -> { options[:auto_increment] = true },
        #   [ "DEFAULT", :quoted_string ] => :set_default
        # }.freeze
        #
        # and then implement a pattern-matching algo.
        #
        #   if value.is_a? Symbol
        #     send(value, *args)
        #   else
        #     value.call(*args)
        #   end
        PARSE_ORDER = %I[
          parse_collate
          parse_not_null
          parse_null
          parse_default
          parse_auto_increment
        ].freeze

        def parse
          debug "ColumnOptionsParser#parse(#{words})"

          PARSE_ORDER.each do |meth|
            next if words.empty?

            debug_meth(meth)
            @words = send(meth)
            debug "options: #{options.inspect}"
          end

          log_unsupported_options
          options
        end

        private

        attr_reader :words

        def parse_collate
          if words[0]&.upcase == "COLLATE"
            options[:collate] = words[1]
            words.slice(2, words.size)
          else
            words
          end
        end

        def parse_not_null
          if words[0]&.upcase == "NOT" && words[1]&.upcase == "NULL"
            options[:null] = false
            words.slice(2, words.size)
          else
            words
          end
        end

        def parse_null
          if words[0]&.upcase == "NULL"
            options[:null] = true
            words.slice(1, words.size)
          else
            words
          end
        end

        def parse_default
          if words[0]&.upcase == "DEFAULT"
            if words[1]&.upcase == "NULL"
              options[:default] = nil
              words.slice(2, words.size)
            else
              default, remaining = read_delimited_string(1, words.size,
                                                         delim: "'")
              options[:default] = default
              remaining
            end
          else
            words
          end
        end

        def parse_auto_increment
          if words[0]&.upcase == "AUTO_INCREMENT"
            options[:auto_increment] = true
            words.slice(1, words.size)
          else
            words
          end
        end

        def debug_meth(method)
          debug "#{method} '#{words.join("', '")}'"
        end

        # returns an array containing - the string read, and the new value
        # to use for words
        def read_delimited_string(from = 0, to = words.size, delim: "'")
          chrs = StringIO.new(words.slice(from, to).join(" "))
          getc(delim, io: chrs)
          [read_to_next(delim, io: chrs), chrs.read.split(" ")]
        end

        def log_unsupported_options
          return if words.empty?

          debug "ColumnOptionsParser found unsupported options: " \
                "#{words.join(' ')}"
        end
      end
    end
  end
end
