module DatDirec
  module Helpers
    module Pluraliser
      # this is a very simple pluraliser
      # we can always switch it out for ActiveSupport's Inflector if needed
      def pluralise(n, word)
        if n == 1
          "#{n} #{word}"
        else
          "#{n} #{word}s"
        end
      end
    end
  end
end
