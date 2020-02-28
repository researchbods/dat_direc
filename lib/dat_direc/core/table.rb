# frozen_string_literal: true

module DatDirec
  # Represents a table in a (hopefully) database-agnostic manner
  class Table
    attr_reader :name

    def initialize(name, columns: nil, indexes: nil, options: nil)
      @name = name.dup.freeze
      @columns = Hash[columns.map { |x| [x.name, x] }] if columns
      @indexes = indexes if indexes
      @options = options if options
    end

    def add_options(options)
      @options.merge!(options)
    end

    def add_column(column)
      columns[column.name] = column
    end

    def options
      @options ||= {}
    end

    def indexes
      @indexes ||= []
    end

    def columns
      @columns ||= {}
    end
  end
end
