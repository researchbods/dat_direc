# frozen_string_literal: true

module DatDirec
  # Container module for the abstract migrations DatDirec supports.
  # After 1.0, Migrations should only be added or removed from this module when
  # new major versions are released in order to ensure custom
  # MigrationGenerators do not break

  # There is no standard API for a migration nor any registration mechanism as
  # it is expected that MigrationsGenerators and ReconciliationStrategies know
  # how to create and introspect a Migration, respectively.
  #
  # Migrations are essentially expected to be value objects with little in the
  # way of behaviour. Structs would probably be an ideal way to make them. I'm
  # not 100% on this yet since I haven't (at time of writing) written any
  # ReconciliationStrategies, Migrations, or MigrationGenerators
  module Migrations
    CreateTable = Struct.new(:table)
    DropTable = Struct.new(:table_name)
  end
end
