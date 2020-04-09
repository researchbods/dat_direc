# frozen_string_literal: true

module DatDirec
  # Classes which test a set of databases to determine the differences
  # between them.
  #
  # There'll be a protocol description here soon
  #
  # If I knew more about physics this would be some kind of reference to the
  # works of Dirac
  module Differs
    # Module for enforcing differ protocol implementation correctness
    module DifferProtocolEnforcer
      def self.reason_not_implemented_by(differ)
        if !differ.is_a? Class
          "attempted to register a non-class differ: #{differ}"
        elsif !differ.respond_to?(:priority)
          "#{differ.name} does not implement the self.priority method"
        elsif !differ.instance_methods.index(:diff)
          "#{differ.name} does not implement the #diff method"
        end
      end

      def self.raise_if_not_implemented_by(differ)
        reason = reason_not_implemented_by(differ)
        return if reason.nil?

        raise BadDifferError, reason
      end
    end

    # error message when the differ doesn't implement the differ protocol
    # (currently just needs a priority class method)
    class BadDifferError < StandardError; end

    # registers a differ.
    def self.register(differ)
      DifferProtocolEnforcer.raise_if_not_implemented_by(differ)

      differs << differ
    end

    def self.diff(databases)
      results = []
      differs.to_a.sort_by(&:priority).each do |differ|
        results += differ.new(databases).diff
      end
      results
    end

    def self.differs
      @differs ||= Set.new
    end
    class << self; private :differs; end
  end
end
