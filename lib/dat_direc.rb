# frozen_string_literal: true

# DatDirec is a database difference reconciler.
# If you have N installs of an application all with slightly different database
# structures, and you want to have N installs with the *same* database structure
# this tool is for you!
#
# It works by:
# 1. Parsing database dumps (using the code in the DatDirec::DumpParsers
#    namespace) into a database-engine-agnostic form (DatDirec::Database,
#    DatDirec::Table, DatDirec::Column, DatDirec::Index)
# 2. Detecting various classes of differences between the databases (this code
#    lives in the DatDirec::Differs namespace)
# 3. Prompting the user to determine what actions to take to reconcile the
#    differences between the databases (DatDirec::App::StrategyPrompter)
# 4. Generating migrations based on those actions (this code lives in the
#    DatDirec::MigrationGenerators namespace.
#
# As much as possible, the UI code is exclusively kept in the DatDirec::App
# class and all the hard work is performed elsewhere.
#
# Initially this project targets MySQL and Rails migrations, but should be
# structured sufficiently well that adding support for other database engines
# and migration frameworks is pretty easy and doesn't require modifying any of
# the core.
module DatDirec
end
require "dat_direc/core/database"
require "dat_direc/core/column"
require "dat_direc/core/index"
require "dat_direc/core/table"
#require "dat_direc/migration_generators"
require "dat_direc/dump_parsers"
