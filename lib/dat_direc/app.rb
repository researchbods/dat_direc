# frozen_string_literal: true

require "thor"
require "dat_direc/app/debug"
require "dat_direc/differs"

module DatDirec
  # command line interface for DatDirec
  module CLI
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
        @diff.each_with_index do |d, idx|
          prompt_for_action(d, idx, @diff.size)
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

      def prompt_for_action(diff, idx, count)
        loop do
          actions = actions_for(diff)

          say("(#{idx}/#{count}) #{diff.description}", :bold)
          action = ask("    How do we reconcile this?", :bold, limited_to: actions)
          say("")

          action = handle_builtin_action(diff, action)
          break action unless action.nil?
        end
      end

      BUILTIN_ACTIONS = {
        "details" => :handle_details,
        "save" => :handle_save,
        "help" => :handle_help,
      }.freeze

      def handle_builtin_action(diff, action)
        handler = BUILTIN_ACTIONS[action]
        return action if handler.nil?

        send(handler, diff)
        nil
      end

      def handle_details(diff)
        say(diff.details.to_s + "\n\n")
      end

      def handle_save(_diff)
        say("    saving is not supported yet\n\n")
      end

      def handle_help(diff)
        help_text = ["Actions available:"]
        help_text << "  help - output this help text!"
        help_text << "  details - output detailed information about the diff" if diff.respond_to?(:details)
        help_text << "  save - saves all decisions made so far and quits"
        help_text += diff.strategies.map(&:help_text)
        say("    " + help_text.join("\n    ") + "\n\n")
      end

      def actions_for(diff)
        actions = diff.strategies.map(&:name)
        actions << "details" if diff.respond_to?(:details)
        actions << "save"
        actions << "help"
        actions
      end

      def debug_say(*args)
        if options[:debug]
          say(*args)
        end
      end

      def parse_databases(files)
        say "Parsing databases..."
        @databases = files.map do |sql|
          File.open(sql, 'r') do |io|
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
