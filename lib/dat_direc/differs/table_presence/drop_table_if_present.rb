# frozen_string_literal: true

module DatDirec
  module Differs
    module TablePresence
      # Reconciliation strategy for dropping a table
      class DropTableIfPresent
        def self.strategy_name
          "drop"
        end

        def self.help_text
          "drops the table on all databases that have it"
        end

        def initialize(diff)
          @diff = diff
        end

        def migration
          Migrations::DropTable.new(table_name)
        end

        private

        def table_name
          @diff.table
        end
      end
    end
  end
end
