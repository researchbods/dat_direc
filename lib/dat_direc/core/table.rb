# frozen_string_literal: true

module DatDirec
  # Represents a table in a (hopefully) database-agnostic manner
  class Table
    attr_reader :name

    def initialize(name)
      @name = name.dup.freeze
    end

    def add_options(options)
      @options.merge!(options)
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
