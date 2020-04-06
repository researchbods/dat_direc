# frozen_string_literal: true

module DatDirec
  module MigrationGenerators
    class ActiveRecord
      class CreateTable
        def initialize(migration)
          @table = migration.table
        end

        def generate_up
          <<~MIGRATION
            unless table_exists?(:#{@table.name})
              create_table :#{@table.name} do |t|
                #{indent(4, @table.columns.map(&method(:column)))}
              end
            end
          MIGRATION
        end

        private

        def indent(indent, array)
          indent = " " * indent
          indent + array.join("\n#{indent}")
        end

        def column(col)
          "t.#{col.type} :#{col.name}, #{col.options.inspect}"
        end
      end
    end
  end
end
