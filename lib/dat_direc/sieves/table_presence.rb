module DatDirec
  module Sieves
    # Checks that databases all have the same list of tables
    class TablePresence
      class Difference
        def initialize(table, data)
          @table = table
          @data
        end

        def description
          if times_found >= times_not_found
            "#{table} found in #{pluralise(times_found, "database")}, but not in #{pluralise(times_not_found, "database")}"
          else
            "#{table} not found in #{pluralise(times_not_found, "database")}, but found in #{pluralise(times_found, "database")}"
          end
        end

        def times_found
          @times_found ||= @data.count(&:found?)
        end

        def times_not_found
          @times_not_found ||= @data.count - times_found
        end
      end

      Found = Struct.new(:database, :table) do
        def found?
          true
        end
      end

      NotFound = Struct.new(:database, :table) do
        def found?
          false
        end
      end

      def new(databases)
        @databases = databases
      end

      def differences
        @differences ||= raw_differences.delete_if do |_table_name, diffs|
          diffs.values.all?(&:found?)
        end
      end

      private

      def raw_differences
        tables.map do |table|
          databases.map do |db|
            difference_for(db, table)
          end
        end
      end


      def difference_for(db, table)
        if db.tables.key? table_name
          Found.new(db, table_name)
        else
          NotFound.new(db, table_name)
        end
      end

      # TODO: refactor to base class
      def tables
        @tables ||= begin
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
