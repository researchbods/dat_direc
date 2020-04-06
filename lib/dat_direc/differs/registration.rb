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
    class << self
      # registers a differ.
      def register(differ)
        unless differ.respond_to?(:priority)
          raise "#{differ} does not respond to #priority"
        end

        differs.push(differ)
      end

      def diff(databases)
        results = []
        differs.sort_by(&:priority).each do |differ|
          results += differ.new(databases).diff
        end
        results
      end

      private

      def differs
        @differs ||= []
      end
    end
  end
end
