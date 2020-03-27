module DatDirec
  module Differs
    class Base
      def initialize(databases)
        @databases = databases
      end

      private

      attr_reader :databases

      # this could probably be refactored into a Databases class - so it only
      # needs calculate
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
