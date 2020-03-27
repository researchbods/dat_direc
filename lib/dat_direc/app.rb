# frozen_string_literal: true

require "thor"
require "dat_direc/app/debug"
require "dat_direc/differs"
require "dat_direc/app/strategy_prompter"

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

      desc "diff FILE...", "Discovers the differences between a number of database structures"
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

      desc "decide", "Prompts you for decisions on what actions to take to reconcile the differences found"
      def decide(*files)
        parse_databases(files)
        diff_databases
        @diff.each_with_index do |diff, idx|
          res = execute_strategy(diff, idx, @diff.size)

          break if res == :exit
        end
      end

      desc "generate", "Generates migrations to reconcile the differences in the databases"
      method_option :decisions_file, type: :string, default: nil
      def generate
        invoke "decide" if options[:decisions_file].nil?
      end

      def self.exit_on_failure?
        true
      end

      private

      def execute_strategy(diff, idx)
        strat = StrategyDecider.new(diff, debug: debug)
                               .prompt_for_strategy(idx: idx, count: @diff.size)
        if strat == "save"
          save
          :exit
        else
          diff.strategy(stategy).execute
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
            parser = DatDirec::DumpParsers.find_parser(io)
            if parser
              debug_say("parsing #{sql} using #{parser}")
              db = parser.new(io).parse
              db.name = File.basename(sql)
              db
            else
              debug_say("couldn't find a parser for #{sql} - ignoring this file")
              nil
            end
          end
        end
      end

      def diff_databases
        say "Calculating differences..."
        @diff = Differs.diff(@databases.compact)
        debug_say "Finished"
      end
    end
  end
end
