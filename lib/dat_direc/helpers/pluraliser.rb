# frozen_string_literal: true

module DatDirec
  module Helpers
    # Helper for pluralising words
    module Pluraliser
      # Outputs a number and a word, with the word pluralised if needed. The
      # pluralisation is very simple - literally just adding an 's'. If we need
      # more complex pluralisation then we should probably just throw this away
      # and use ActiveSupport::Inflector
      def pluralise(num, word)
        if num == 1
          "#{num} #{word}"
        else
          "#{num} #{word}s"
        end
      end
    end
  end
end
