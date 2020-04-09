# frozen_string_literal: true

module DatDirec
  # Functionless module for documenting the protocol that Diffs should implement
  module DiffProtocol
    def strategies; end

    def strategy(name); end

    def details; end
  end
end
