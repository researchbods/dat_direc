require "dat_direc/core/database"
require "dat_direc/sieves/table_presence"

RSpec.describe DatDirec::Sieves::TablePresence do
  DD = DatDirec
  describe "#differences" do
    subject { described_class.new(databases).differences }

    context "with two databases" do
      let(:databases) { [database_a, database_b] }
      let(:database_a) { DD::Database.new }
      let(:database_b) { DD::Database.new }

      context "with no tables in either" do
        it "returns empty array" do
          expect(subject).to eq []
        end
      end
    end
  end
end
