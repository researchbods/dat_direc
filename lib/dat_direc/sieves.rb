module DatDirec
  # classes which test a set of databases to determine the differences
  # between them.
  #
  # There'll be a protocol description here soon
  #
  # If I knew more about physics this would be some kind of reference to the
  # works of Dirac
  module Sieves
  end
end

Dir[File.dirname(__FILE__) + "/sieves/*.rb"].sort.each { |f| require f }
