# frozen_string_literal: true

require "dat_direc/migrations"

RSpec.shared_examples_for "a migration generator" do
  it { is_expected.to respond_to(:generate_up) }
  it { is_expected.to respond_to(:generate_file) }
  let(:example_column_a) { DD::Column.new("column_a", "int", limit: 11) }
  let(:example_index_a) do
    DD::Index.new(name: "index_column_a",
                  columns: ["column_a"],
                  type: "index")
  end
  let(:example_table) do
    DD::Table.new("Farg",
                  columns: [example_column_a],
                  indexes: [example_index_a])
  end

  describe "#generate_up supports all migration types" do
    subject { described_class.new.generate_up(migration) }

    context "when passed a CreateTable" do
      let(:migration) { DD::Migrations::CreateTable.new(example_table) }

      it "does not raise an error" do
        expect { subject }.not_to raise_error
      end
    end

    context "when passed a DropTable" do
      let(:migration) { DD::Migrations::DropTable.new("example_table") }

      it "does not raise an error" do
        expect { subject }.not_to raise_error
      end
    end

    context "when passed some other kind of data" do
      let(:migration) { Struct.new("fake_data").new(1) }

      it "raises an error" do
        expect { subject }.to raise_error(StandardError)
      end
    end
  end
end
