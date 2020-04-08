# frozen_string_literal: true

require "dat_direc/helpers/pluraliser"

module DatDirec
  # subclasses of Diff should either set @strategies during initialize,
  # or override the strategies method
  class Diff
    def initialize(states)
      @states = states.freeze
      @strategies ||= []
    end

    def strategy(name)
      strategies.find { |x| x.strategy_name == name }&.new(self)
    end

    def description
      "A summary of the diff should be here, but the implementor of " \
        "#{self.class.name} did not provide one"
    end

    def details
      <<~DETAILS
        Longer-form information about the differences between the databases
        should be here, but the implementor of #{self.class.name} did not
        provide any
      DETAILS
    end

    attr_reader :states, :strategies

    include Helpers::Pluraliser
  end
end
