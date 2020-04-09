# frozen_string_literal: true

module DatDirec
  # Functionless module purely to document the protocol that Differs should
  # adhere to
  module DifferProtocol
    # A priority number which is used to determine when a differ runs - lower
    # means it runs earlier. Should be an int but it probably doesn't matter.
    # This allows migrations from earlier differs to alter later differs. For
    # example, if the outcome of a TablePresence is that the table can be
    # dropped, all the later differs that would've run over that table can
    # skip over it.
    #
    # Predefined numbers:
    # 0 - TablePresence
    # 1 - ColumnPresence
    # 2 - ColumnDetails
    # 3 - IndexPresence
    # 4 - IndexDetails
    #
    # @return [Numeric] The priority value for this Differ
    def self.priority; end

    # Calculates the difference between the databases for this type of
    # difference. Differences are represented in custom objects per type of
    # differ, though there is a protocol to adhere to. See DiffProtocol for
    # more info.
    #
    # (e.g. TablePresence returns a TablePresence::Diff)
    # @param databases [[Database]] The databases to perform the difference
    # between
    # @returns A subclass of BaseDiff
    def diff(databases); end
  end
end
