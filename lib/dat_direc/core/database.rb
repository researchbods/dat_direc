# frozen_string_literal: true

module DatDirec
  # Engine-agnostic representation of a database
  # this is the outer-most structure used to represent a set of tables within
  # the same database. the database may optionally have a name - this is only
  # used to identify which databases have which versions of columns etc. in the
  # diffs, so the name itself isn't of great importance.
  class Database
    attr_reader :type
    attr_accessor :name

    def initialize(type, tables: nil, name: nil)
      @type = type
      @name = name
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
