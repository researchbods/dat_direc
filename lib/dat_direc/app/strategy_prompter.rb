# frozen_string_literal: true

module DatDirec
  module CLI
    # prompts the user to pick a strategy for a given diff, handling 'help' and
    # 'details' responses internally. 'save' is returned to the
    class StrategyPrompter
      include Thor::Shell

      def initialize(diff, debug: false)
        @debug = debug
        @diff = diff
      end

      def prompt_for_strategy(idx: 1, count: 1)
        loop do
          say("(#{idx}/#{count}) #{@diff.description}", :bold)
          action = ask("    How do we reconcile this?",
                       :bold,
                       limited_to: actions)
          say("")

          strategy = handle_action(action)
          return strategy unless strategy.nil?
        end
      end

      private

      def handle_action(action)
        if action == "details"
          handle_details
          nil
        elsif action == "help"
          handle_help
          nil
        elsif action == "quite"
          :exit
        else
          action
        end
      end

      def handle_details
        say "#{@diff.details}\n\n"
      end

      def handle_help
        say "    #{help_text.join("\n    ")}\n\n"
      end

      def help_text
        @help_text ||=
          begin
            text = ["Actions available:", ""]
            text += @diff.strategies.map do |s|
              "  #{set_color s.strategy_name, :bold, :blue} - #{s.help_text}"
            end
            text << "  #{set_color "help", :bold, :green } - output this help text!"
            if @diff.respond_to?(:details)
              text << "  #{set_color "details", :bold, :green} - output detailed information about this diff"
            end
            text << "  #{set_color "save", :bold, :yellow} - saves all decisions made so far and quits"
          end
      end

      def actions
        @actions ||= begin
                       actions = @diff.strategies.map(&:strategy_name)
                       actions << "details" if @diff.respond_to?(:details)
                       actions << "save"
                       actions << "help"
                       actions
                     end
      end

      def debug_say(*args)
        say(*args) if @debug
      end
    end
  end
end
