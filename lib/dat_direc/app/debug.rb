# frozen_string_literal: true

require "dat_direc/dump_parsers/mysql"
require "dat_direc/differs"
require "pp"

module DatDirec
  module CLI
    class Debug < Thor
      desc "read FILE", "Reads an SQL file and outputs information about it"
      def read(file)
        io = File.open(file, "r")
        parser = DumpParsers.find_parser(io).new(io)
        database = parser.parse

        puts <<~INFO
          SQL file is for a #{parser.name} database with #{database.tables.count} tables.

          Tables
          ------

          #{database.tables.values.map do |table|
            "#{table.name} (#{table.columns.count} columns, #{table.indexes.count} indexes)"
          end.join("\n")}

        INFO
      end

      desc "differs", "Lists off all the differs registered"
      def differs
        puts Differs.send(:differs).inspect
      end
    end
  end
end
