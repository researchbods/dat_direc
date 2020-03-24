# frozen_string_literal: true

module DatDirec
  class Database
    attr_reader :type
    attr_accessor :name

    def initialize(type, tables: nil)
      @type = type
      @tables = Hash[tables.map { |t| [t.name, t] }] if tables
    end

    def add_table(table)
      tables[table.name] = table
    end

    def tables
      @tables ||= {}
    end

    # TODO: test
    def ==(other)
      (tables.keys - other.tables.keys).empty? &&
        tables.all? do |k, v|
          other.tables[k] && other.tables[k] == v
        end
    end
  end
end
