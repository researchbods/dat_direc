# frozen_string_literal: true

module DatDirec
  # module containing the migration generators. These are the code generators
  # which realise abstract Migration objects into code that can be run as a
  # migration (e.g an ActiveRecord::Migration subclass)
  # Haven't designed the API for them yet but I think it'll look something like
  # this:
  #
  # #initialize must support being called with no arguments
  # #generate_up takes a Migration object and returns a string containing just
  #  the code one would need to add to an 'up' section of a
  #  migration without indentation. It is recommended that this job is
  #  dispatched to other classes designed for the purpose of each migration
  #  type, in order to keep complexity down.
  #  (See the ActiveRecordMigration class for an example of this)
  # #generate_file takes a directory name and an array of migrations and writes
  #                a complete migration file for them, with a correct filename.
  #                Note that generating a correct class name (for example) is
  #                up to the MigrationGenerator itself - DatDirecMigration
  #                followed by a unique number (a timestamp for example) would
  #                be fine.
  module MigrationGenerators
  end
end
Dir[File.dirname(__FILE__) + "/migration_generators/*.rb"]
  .sort
  .each { |f| require f }
