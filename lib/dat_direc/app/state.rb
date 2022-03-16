module DatDirec
  module CLI
    class ReconciliationState
      def initialize(databases)
        @databases = databases
      end

      def apply_strategy(strategy)
        migration = s.migration
        migrations << migration
        remove_obsolete_diffs(s)
      end

      def save(io)
        io.write(Marshal.dump(self))
      end

      private

      def remove_obsolete_diffs(strategy)
      end

      def diffs
        return @diffs if @diffs

        debug_say "Calculating differences..."
        @diffs = Differs.diff(@databases.compact)
        debug_say "Finished"
        diffs
      end
    end
  end
end
