require "dat_direc/helpers/pluraliser"

module DatDirec
  module Differs
    class BaseDiff
      def initialize(states)
        @states = states.freeze
      end

      attr_reader :states

      include Helpers::Pluraliser
    end
  end
end
