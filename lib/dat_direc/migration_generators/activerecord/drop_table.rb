# frozen_string_literal: true

module DatDirec
  module MigrationGenerators
    class ActiveRecord
      class DropTable
        def initialize(migration)
          @table_name = migration
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
