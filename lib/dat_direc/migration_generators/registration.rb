# frozen_string_literal: true

module DatDirec
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
