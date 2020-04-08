# frozen_string_literal: true

require "dat_direc/migration_generators/registration"
require "dat_direc/migration_generators/activerecord/create_table"
require "dat_direc/migration_generators/activerecord/drop_table"

module DatDirec
  module MigrationGenerators
    # Generates ActiveRecord / Rails migrations. Currently these target
    # compatibility with ActiveRecord/Rails 4. It would be nice to figure out
    # a way to make DatDirec take options for this.
    class ActiveRecord
      GENERATORS = {
        Migrations::CreateTable => CreateTable,
        Migrations::DropTable => DropTable,
      }.freeze

      def generate_up(migration)
        generator = GENERATORS[migration.class]
        if generator.nil?
          return "raise 'Unsupported migration type #{migration.class.name}'"
        end

        generator.new(migration).generate_up
      end

      def generate_file(migrations)
        <<~MIGRATION
          class DatDirecMigration#{Time.now.strftime('%Y%m%d%H%M')} < ActiveRecord::Migration
            def up
              #{migrations.map do |m|
                generate_up(m).split("\n") + ['']
              end.flatten.join("\n    ")}
            end
          end
        MIGRATION
      end
    end
  end
  MigrationGenerators.register(MigrationGenerators::ActiveRecord)
end
