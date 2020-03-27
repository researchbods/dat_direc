# frozen_string_literal: true

require "dat_direc/helpers/pluraliser"

module DatDirec
  # subclasses of BaseDiff should either set @strategies during initialize,
  # or override the strategies method
  class BaseDiff
    def initialize(states)
      @states = states.freeze
    end

    def strategy(name)
      strategies.find { |x| x.name == name }.new(self)
    end

    attr_reader :states, :strategies

    include Helpers::Pluraliser
  end
end
