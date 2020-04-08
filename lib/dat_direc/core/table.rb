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

    # TODO: test
    def ==(other)
      name.eql?(other.name) &&
        options.eql?(other.options) &&
        same_columns?(other) &&
        same_indexes?(other)
    end

    def same_columns?(other)
      Set.new(columns.keys) == Set.new(other.columns.keys) &&
        columns.all? { |k, v| other.columns[k] && other.columns[k] == v }
    end

    def same_indexes?(other)
      indexes_self = indexes_by_name
      indexes_other = indexes_by_name(other)

      Set.new(indexes_self.keys) == Set.new(indexes_other.keys) &&
        indexes_self.all? { |k, v| indexes_other[k] && indexes_other[k] == v }
    end

    private

    def indexes_by_name(obj = self)
      Hash[obj.indexes.map { |i| [i.name, i] }]
    end
  end
end
