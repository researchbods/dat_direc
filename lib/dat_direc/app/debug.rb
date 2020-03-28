# frozen_string_literal: true

require "dat_direc/dump_parsers/mysql"
require "dat_direc/differs"
require "pp"

# rubocop:disable Metrics/AbcSize Metrics/MethodLength

module DatDirec
  module CLI
    # Debug commands that I found useful while working on DatDirec.
    # Likely to be brittle and get thrown away before 1.0
    class Debug < Thor
      desc "read FILE", "Reads an SQL file and outputs information about it"
      def read(file)
        io = File.open(file, "r")
        parser = DumpParsers.find_parser(io).new(io)
        database = parser.parse
        tables = database.tables.values.map do |table|
          "#{table.name} " \
            "(#{table.columns.count} columns, #{table.indexes.count} indexes)"
        end

        puts <<~INFO
          #{parser.name} database with #{database.tables.count} tables.

          Tables
          ------

          #{tables.join("\n")}

        INFO
      end

      desc "differs", "Lists off all the differs registered"
      def differs
        puts Differs.send(:differs).inspect
      end
    end
  end
end

# rubocop:enable Metrics/AbcSize Metrics/MethodLength
