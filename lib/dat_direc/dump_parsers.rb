# frozen_string_literal: true

Dir[File.dirname(__FILE__) + "/dump_parsers/*"]
  .sort
  .each { |rb| require rb }
