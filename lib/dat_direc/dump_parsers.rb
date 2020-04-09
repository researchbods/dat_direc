# frozen_string_literal: true

module DatDirec
  module DumpParsers
  end
end

Dir[File.dirname(__FILE__) + "/dump_parsers/*"]
  .sort
  .each { |rb| require rb }
