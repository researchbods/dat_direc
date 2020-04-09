# frozen_string_literal: true

module DatDirec
  # Functionless modiule for documenting the protocol that Strategies should
  # implement
  module StrategyProtocol
    # @return [String] one-word name that the user can type to select this
    #                  strategy
    def self.strategy_name; end

    # @return [String] a one-line piece of information about what the migration
    #                  this strategy creates will do
    def self.help_text; end

    # @param diff The diff (implementor of DiffProtocol) which created this
    #             Strategy. Strategies are tightly coupled to Diffs, so it is
    #             expected that they will know about the diff's API outside the
    #             DiffProtocol
    def initialize(diff); end

    # @return An instance of some kind of struct which serves as an abstract
    #         representation of a migration. See DatDirec::Migrations.
    def migration; end
  end
end
