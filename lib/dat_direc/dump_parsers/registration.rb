# frozen_string_literal: true

module DatDirec
  # Module containing the built-in SQL dump parsers.
  # The module itself is also responsible for handling the list of possible dump
  # parsers. To implement your own dump parser, write a class conforming to the
  # protocol described below, then call
  # DumpParsers.register_parser(YourClassHere)
  #
  # Dump parsers must implement class method #detect, which takes a
  # rewindable IO object and returns a truthy value when the parser is suitable
  # for the IO object. Regardless of whether the parser is suitable, the io
  # object must be rewound by the end of the #detect method's execution
  #
  # They must be able to be initialized with an io object, and must implement a
  # #parse instance method which takes no arguments and returns a
  # DatDirec::Database (or something that quacks like one)
  module DumpParsers
    class BadParserError < StandardError; end

    class << self
      def parsers
        @parsers ||= Set.new
      end

      def find_parser(io)
        parsers.find { |p| p.detect(io) }
      end

      def register_parser(klass)
        unless klass.is_a? Class
          raise BadParserError,
            "attempted to register a parser which was not a class"
        end

        parsers << klass
      end
    end
  end
end
