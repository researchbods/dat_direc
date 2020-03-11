# frozen_string_literal: true

module DatDirec
  # Represents an index in a (hopefully) database-agnostic manner
  class Index
    attr_reader :name, :type, :columns, :options

    def initialize(name:, type:, columns:, options: {})
      @name = name.dup.freeze
      @type = type.dup.freeze
      @columns = columns.dup.freeze
      @options = options.dup.freeze
    end

    def isomorphic?(other)
      columns == other.columns
    end

    # TODO: test
    def ==(other)
      other.name == name &&
        other.type == type &&
        other.columns == columns &&
        other.options == options
    end
  end
end
