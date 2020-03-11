# frozen_string_literal: true

module DatDirec
  module DumpParsers
    class << self
      def parsers
        @parsers ||= Set.new
      end

      def find_parser(io)
        parsers.find { |p| p.detect(io) }
      end

      def register_parser(klass)
        unless klass.is_a? Class
          raise ArgumentError,
                "attempted to register a parser which was not a class"
        end

        parsers << klass
      end
    end
  end
end
