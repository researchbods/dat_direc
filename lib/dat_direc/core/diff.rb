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
      strategies.find { |x| x.name == name }.new(self)
    end

    attr_reader :states, :strategies

    include Helpers::Pluraliser
  end
end
