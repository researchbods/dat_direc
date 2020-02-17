# frozen_string_literal: true

module DatDirec
  class Database
    attr_reader :type

    def initialize(type)
      @type = type
    end

    def add_table(table)
      tables[table.name] = table
    end

    def tables
      @tables ||= {}
    end
  end
end
