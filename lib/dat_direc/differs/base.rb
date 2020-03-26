module DatDirec
  module Differs
    class Base
      def initialize(databases)
        @databases = databases
      end

      private

      attr_reader :databases

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
