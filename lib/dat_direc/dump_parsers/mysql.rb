module DatDirec
  module DumpParsers
    class MySQLDumpParser
      def self.detect(io)
        io.gets =~ /MySQL/
      end

      def initialize(io)
        @io = io
        @table = nil

      end

      def parse
        @database = Database.new
        @io.each do |line|
          next
          parse_line(line)
        end
        @database
      end

      COLUMNS_REGEXP = /\(`([^`]*)`(?:,`([^`]*)`)\)/

      def parse_line(line)
        case line
        when /CREATE TABLE `(.*)`/
          @table = Table.new(Regexp.last_match[1]
        when /^\s*(PRIMARY |UNIQUE )?KEY/
          parse_key(line)
        when /(?: ([A-Z0-9_])(?:=([^ ]*)))?;/
        end
      end

      def parse_key(line)
        KeyParser.new(line).parse
      end

      def parse_column

      end

      class KeyParser
        def initialize(line, line_no)
          @pos = 0
          @io = StringIO.new(line)
          @line_no = line_no
        end

        def parse
          parse_key_type
          parse_key_name if @type != 'PRIMARY'
          parse_key_columns
        end

        def parse_key_type
          type = read_to_next(' ')
          case type
          when "PRIMARY"
            @type = :primary
            read_key
          when "UNIQUE"
            @type = :unique
            read_key
          when "KEY"
            @type = :index
          else
            raise "Unexpected #{type} - expecting PRIMARY, UNIQUE, or KEY on line #{@line_no}"
          end
        end

        def parse_key_name
          @name = parse_delimited_string
        end

        def parse_delimited_string
          delim = read_to_next('`', keep: true)
          raise "Unexpected #{delim} - expecting start of string (`)" if delim != "`"

          read_to_next('`')
        end

        def read_key
          key = read_to_next(' ')
          if key != "KEY"
            raise "Unexpected #{key} - expecting KEY on line #{@line_no}"
          end
        end

        def read_to_next(sep, keep: false)
          str = @io.gets(sep)
          if keep
            str
          else
            str.chomp(sep)
        end
      end
    end
  end
end
