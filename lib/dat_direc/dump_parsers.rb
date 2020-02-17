# frozen_string_literal: true

module DatDirec
  module DumpParsers
    instance_eval do
      def parsers
        @parsers ||= Set.new
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
