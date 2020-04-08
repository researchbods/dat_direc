# frozen_string_literal: true

module DatDirec
  module Differs
    module TablePresence
      # Migration strategy for creating a table which is missing on some
      # databases
      class CreateTableIfMissing
        def self.strategy_name
          "create"
        end

        def self.help_text
          "creates the table if it is not found"
        end

        def initialize(diff)
          @diff = diff
        end

        def migration
          Migrations::CreateTable.new(table)
        end

        private

        def table
          @diff.databases_found
               .first
               .tables[@diff.table]
        end
      end
    end
  end
end
