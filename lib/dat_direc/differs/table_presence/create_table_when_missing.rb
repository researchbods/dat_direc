# frozen_string_literal: true

module DatDirec
  module Differs
    class TablePresence
      class CreateTableWhenMissing
        def self.strategy_name
          "create"
        end

        def initialize(diff)
          @diff = diff
        end

        def migration
          Migrations::CreateTable.new(table)
        end

        private

        def table
          @diff.databases.first.tables[@diff.table]
        end
      end
    end
  end
end
