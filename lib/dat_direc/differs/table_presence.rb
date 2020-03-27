# frozen_string_literal: true

require "dat_direc/core/diff"
require "dat_direc/differs/registration"
require "dat_direc/differs/base"
require "terminal-table"

module DatDirec
  module Differs
    # Checks that databases all have the same list of tables
    class TablePresence < Base
      def self.priority
        0
      end

      def diff
        @diff = tables.map do |table|
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

      class TableDiff < Diff
        attr_reader :table

        def initialize(table, states)
          @table = table
          super(states)
        end

        def description
          if times_found >= times_not_found
            "Table '#{table}' found in #{pluralise(times_found, "database")}, but not in #{pluralise(times_not_found, "other database")}"
          else
            "Table '#{table}' not found in #{pluralise(times_not_found, "database")}, but found in #{pluralise(times_found, "other database")}"
          end
        end

        def details
          data = [databases_found.map(&:name),
                  databases_not_found.map(&:name)]

          Terminal::Table.new(headings: ["Found in", "Not found in"],
                              rows: transpose(data))
        end

        # Transposes array-of-arrays, filling gaps with nil.
        # e.g. turns the following array:
        # [
        #   [ "found 1", "found 2", "found 3" ]
        #   [ "not found 1" ]
        # ]
        # into the following:
        # [
        #   [ "found 1", "not found 1" ]
        #   [ "found 2", nil ]
        #   [ "found 3", nil ]
        # ]
        #
        # There is a more compact implementation (.reduce(&:zip).map(&:flatten))
        # but that truncates arrays where the first array is not the longest.
        # e.g.
        # [
        #   []
        #   [ "not found 1" ]
        # ]
        # becomes [] instead of [[nil, "not found 1"]]
        #
        # my transpose implementation handles the latter case properly,
        # returning [[nil, "not found 1"]]
        #
        # TODO: refactor into a helper or into Diff it's useful elsewhere
        def transpose(arr)
          rows = arr.map(&:size).max
          cols = arr.size

          (0...rows).to_a.map do |row|
            (0...cols).to_a.map do |col|
              arr[col][row]
            end
          end
        end

        # returns array of databases where the table was found
        def databases_found
          states.select(&:found?).map(&:database)
        end

        # returns array of databases where the table was not found
        def databases_not_found
          states.reject(&:found?).map(&:database)
        end

        def times_found
          databases_found.length
        end

        def times_not_found
          databases_not_found.length
        end
      end
    end
  end
end
DatDirec::Differs.register DatDirec::Differs::TablePresence
