module DatDirec
  module DumpParsers
    class MySQL
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

      def parse_line(line)
        case line
        when /CREATE TABLE `(.*)`/
          @table = Table.new(Regexp.last_match[1])
        when /^\s*(PRIMARY |UNIQUE )?KEY/
          parse_key(line)
        when /^\s*(CONSTRAINT )/
          # TODO: support foreign key constraints
        when /(?: ([A-Z0-9_])(?:=([^ ]*)))?;/

        end
      end

      def parse_key(line)
        KeyParser.new(line).parse
      end

      def parse_column

      end
    end
  end
