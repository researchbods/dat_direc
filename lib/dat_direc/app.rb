require "thor"
require "dat_direc/app/debug"

module DatDirec
  # command line interface for DatDirec
  module CLI
    class App < Thor
      desc "debug", "Debug tools used during development of DatDirec"
      subcommand "debug", Debug

      def self.exit_on_failure?
        true
      end
    end
  end
end
