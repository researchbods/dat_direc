# frozen_string_literal: true

module DatDirec
  module Differs
    class TablePresence
      class DropTableIfPresent
        def self.strategy_name
          "drop"
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
