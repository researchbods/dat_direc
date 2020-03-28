# frozen_string_literal: true

module DatDirec
  module Differs
    # Base class to make implementing differs easier.
    #
    # Subclasses must implement the class method #priority returning a number
    # (where a lower number means the differ runs earlier) and the instance
    # method #diff, which performs the diff. See TablePresence for an example
    class Base
      def initialize(databases)
        @databases = databases
      end

      private

      attr_reader :databases

      # this could probably be refactored into a Databases class - so it only
      # needs calculating once during the program's run
      def table_names
        @table_names ||= begin
                           tables = Set.new
                           databases.each do |db|
                             db.tables.keys.each do |tbl|
                               tables << tbl
                             end
                           end
                           tables
                         end
      end
    end
  end
end
