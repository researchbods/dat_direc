# frozen_string_literal: true

require "dat_direc/migrations"

module DatDirec
  module MigrationGenerators
    class ActiveRecord
      # Writes ActiveRecord code to perform a DropTable migration.
      class DropTable
        def initialize(migration)
          unless migration.is_a? Migrations::DropTable
            raise UnsupportedMigrationError, migration
          end

          @table_name = migration.table_name
        end

        def generate_up
          <<~MIGRATION
            drop_table :#{@table_name} if table_exists?(:#{@table_name})
          MIGRATION
        end
      end
    end
  end
end
