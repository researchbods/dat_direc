# frozen_string_literal: true

module DatDirec
  # Module containing all the classes which transform abstract migrations into
  # concrete implementations for the database framework of your choice.
  module MigrationGenerators
    class << self
      # registers a generator.
      def register(generator)
        generators[generator.name.split("::").last.downcase] = generator
      end

      private

      def generators
        @generators ||= {}
      end
    end
  end
end
