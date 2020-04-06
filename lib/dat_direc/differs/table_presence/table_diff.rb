# frozen_string_literal: true

require "dat_direc/core/diff"
require "dat_direc/differs/table_presence/create_table_if_missing"
require "dat_direc/differs/table_presence/drop_table_if_present"
require "terminal-table"

module DatDirec
  module Differs
    class TablePresence
      # The Diff returned by TablePresence#diff
      class TableDiff < Diff
        attr_reader :table

        def initialize(table, states)
          @table = table
          @strategies = [CreateTableIfMissing, DropTableIfPresent]
          super(states)
        end

        def description
          if times_found >= times_not_found
            "Table '#{table}' found in #{pluralise(times_found, 'database')}, "\
              "but not in #{pluralise(times_not_found, 'other database')}"
          else
            "Table '#{table}' not found in " \
              "#{pluralise(times_not_found, 'database')}, but found in " \
              "#{pluralise(times_found, 'other database')}"
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
