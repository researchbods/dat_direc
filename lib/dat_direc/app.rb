# frozen_string_literal: true

require "thor"
require "dat_direc/app/debug"
require "dat_direc/differs"
require "dat_direc/app/strategy_prompter"
require "dat_direc/migration_generators"

module DatDirec
  # command line interface for DatDirec
  module CLI
    # Main application for DatDirec.
    # As much as possible functionality should be extracted out to subcommands -
    # see Debug for an example.
    class App < Thor
      class_option :debug, type: :boolean

      desc "debug", "Debug tools used during development of DatDirec"
      subcommand "debug", Debug

      desc "diff FILE...",
           "Discovers the differences between a number of database structures"
      def diff(*files)
        parse_databases(files)

        diff_databases
        @diff.each do |d|
          if d.respond_to?(:details)
            say "#{d.description}\n\n#{d.details}\n\n"
          else
            puts d.description
          end
        end
      end

      desc "decide",
           "Prompts you for decisions on what actions to take" \
           "to reconcile the differences found"
      def decide(*files)
        parse_databases(files)
        diff_databases
        @diff.each_with_index do |diff, idx|
          migration = execute_strategy(diff, idx)
          break if migration == :exit

          puts migration.inspect
        end
      end

      desc "generate",
           "Generates migrations to reconcile the differences in the databases"
      def generate(*files)
        generator_name = "activerecord"
        generator = MigrationGenerators[generator_name]
        puts "activerecord generator: #{generator}"
        parse_databases(files)
        diff_databases
        exiting = false
        migrations = []
        @diff.each_with_index do |diff, idx|
          strategy = pick_strategy(diff, idx)
          if strategy == :exit
            # exiting = true
            break
          end

          migrations << strategy.migration
        end

        return if exiting

        debug_say "Migrations: #{migrations.inspect}"
        say generator.new.generate_file(migrations)
      end

      def self.exit_on_failure?
        true
      end

      private

      def pick_strategy(diff, idx)
        strat = StrategyPrompter.new(diff, debug: debug)
                                .prompt_for_strategy(idx: idx,
                                                     count: @diff.size)
        if strat == "save"
          save
          :exit
        else
          s = diff.strategy(strat)
          debug_say "Strategy '#{strat}': #{s} (strategies: #{diff.strategies})"

          m = s.migration
          debug_say "Migration: #{m}"
          m
        end
      end

      def save
        puts "saving is not supported"
      end

      def debug_say(*args)
        say(*args) if options[:debug]
      end

      def parse_databases(files)
        say "Parsing databases..."
        @databases = files.map do |sql|
          File.open(sql, "r") do |io|
            parse_db(io)
          end
        end
      end

      def parse_db(io)
        parser = DatDirec::DumpParsers.find_parser(io)
        name = File.basename(io.path)
        unless parser
          debug_say("couldn't find a parser for #{name} - ignoring this file")
          return nil
        end

        debug_say("parsing #{name} using #{parser}")
        db = parser.new(io).parse
        db.name = name
        db
      end

      def diff_databases
        say "Calculating differences..."
        @diff = Differs.diff(@databases.compact)
        debug_say "Finished"
      end
    end
  end
end
