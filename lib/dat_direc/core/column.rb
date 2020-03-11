# frozen_string_literal: true

module DatDirec
  # Represents a column in a (hopefully) database-agnostic manner
  class Column
    attr_reader :name, :type, :options
    def initialize(name, type, **options)
      @name = name
      @type = type
      @options = options
    end

    # TODO: test
    def ==(other)
      other.name == name &&
        other.type == type &&
        other.options == options
    end
  end
end
