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
          say("(#{idx}/#{count}) #{diff.description}", :bold)
          action = ask("    How do we reconcile this?",
                       :bold,
                       limited_to: actions)
          say("")

          strategy = handle_action(action)
          return strategy unless strategy.nil?
        end
      end

      private

      def handle_builtin_action(action)
        handler = BUILTIN_ACTIONS[action]
        return action if handler.nil?

        if action == "details"
          handle_details
        elsif action == "help"
          handle_help
        end
        nil
      end

      def handle_details
        say "#{diff.details}\n\n"
      end

      def handle_help
        say "    #{help_text.join("\n    ")}\n\n"
      end

      def help_text
        @help_text ||=
          begin
            help_text = ["Actions available:"]
            help_text << "  help - output this help text!"
            if diff.respond_to?(:details)
              help_text << "  details - output detailed information about this diff"
            end
            help_text << "  save - saves all decisions made so far and quits"
            help_text + diff.strategies.map(&:help_text)
          end
      end

      def actions
        @actions ||= begin
                       actions = diff.strategies.map(&:name)
                       actions << "details" if diff.respond_to?(:details)
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
