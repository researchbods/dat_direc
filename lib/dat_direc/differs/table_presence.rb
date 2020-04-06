# frozen_string_literal: true

require "dat_direc/differs/registration"
require "dat_direc/differs/base"

module DatDirec
  module Differs
    # Checks that databases all have the same list of tables
    class TablePresence < Base
      def self.priority
        # TablePresence has a low priority because it needs to run earliest - no
        # point comparing a column across the databases if it's in a table
        # that's going to be removed.
        0
      end

      def diff
        @diff = table_names.map do |table|
          diff_for(table)
        end

        remove_identical_states
        @diff
      end

      private

      def remove_identical_states
        @diff.delete_if do |result|
          result.states.all?(&:found?)
        end
      end

      def diff_for(table)
        TableDiff.new(table,
                      databases.map do |db|
                        state_for(db, table)
                      end)
      end

      def state_for(db, table_name)
        if db.tables.key? table_name
          Found.new(db, table_name)
        else
          NotFound.new(db, table_name)
        end
      end

      # Represents the fact that a table was found on a database
      Found = Struct.new(:database, :table) do
        def found?
          true
        end
      end

      # Represents the fact that a table was not found on a database
      NotFound = Struct.new(:database, :table) do
        def found?
          false
        end
      end

    end
  end
end
DatDirec::Differs.register DatDirec::Differs::TablePresence
