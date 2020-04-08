# frozen_string_literal: true

RSpec.describe DatDirec::Table do
  subject(:table) { described_class.new(name,
                                        columns: columns,
                                        indexes: indexes,
                                        options: options) }
  describe "#==" do
    subject { table == other }

    let(:name) { "jeff_the_table" }
    let(:columns) { [] }
    let(:indexes) { [] }
    let(:options) { {} }

    let(:other) { described_class.new(other_name,
                                      columns: other_columns,
                                      indexes: other_indexes,
                                      options: other_options) }
    let(:other_name) { name.dup }
    let(:other_columns) { columns.dup }
    let(:other_indexes) { indexes.dup }
    let(:other_options) { {} }

    context "when comparing two identical tables" do
      context "when neither have any columns" do
        it { is_expected.to be true }
      end

      context "when both have columns" do
        let(:columns) { [DD::Column.new("test", "int")] }

        it { is_expected.to be true }

        context "and indexes" do
          let(:indexes) { [DD::Index.new(name: "index_test",
                                         columns: ["test"],
                                         type: "index")] }

          it { is_expected.to be true }
        end
      end
    end

    context "when names differ" do
      let(:other_name) { "the_name_of_consequence" }

      it { is_expected.to be false }
    end

    context "when columns differ" do
      let(:other_columns) { [DD::Column.new("test", "int")] }

      it { is_expected.to be false }
    end

    context "when indexes differ" do
      let(:columns) { [DD::Column.new("test", "int")] }
      let(:other_indexes) { [DD::Index.new(name: "index_test",
                                           columns: ["test"],
                                           type: "index")] }

      it { is_expected.to be false }
    end

    context "when options differ" do
      let(:other_options) { { engine: "InnoDB" } }

      it { is_expected.to be false }
    end
  end
end
