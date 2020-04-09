# frozen_string_literal: true

module DatDirec
  # Module containing all the classes which transform abstract migrations into
  # concrete implementations for the database framework of your choice.
  module MigrationGenerators
    # registers a generator.
    def self.register(generator)
      generators[generator.name.split("::").last.downcase] = generator
    end

    def self.[](name)
      generators[name]
    end

    def self.generators
      @generators ||= {}
    end
    # bit of a hack to let me get what I want and still use mutant (see
    # https://github.com/mbj/mutant/issues/258 )
    class << self; private :generators; end
  end
end
