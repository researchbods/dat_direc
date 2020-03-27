# frozen_string_literal: true

module DatDirec
  module Differs
    class << self
      # registers a differ. specify before/after to ensure the differs end up in
      # the right order
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
