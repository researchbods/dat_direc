# frozen_string_literal: true

require "dat_direc/core/database"
require "dat_direc/core/table"
require "dat_direc/differs/table_presence"

RSpec.describe DatDirec::Differs::TablePresence do
  describe "#differences" do
    subject { described_class.new(databases).diff }

    context "with two databases" do
      let(:databases) { [database_a, database_b] }
      let(:database_a) { DD::Database.new("fake", name: "a", tables: tables_a) }
      let(:database_b) { DD::Database.new("fake", name: "b", tables: tables_b) }
      let(:tables_a) { [] }
      let(:tables_b) { [] }

      context "with no tables in either" do
        it "returns empty array" do
          expect(subject).to eq []
        end
      end

      context "with a table in one database but not the other" do
        let(:tables_a) { [DD::Table.new("test")] }

        it "returns a result" do
          expect(subject.length).to eq 1
          expect(subject.first.description).to eq "Table 'test' found in 1 database, but not in 1 other database"
        end
      end

      context "with a table in both databases" do
        let(:tables_a) { [DD::Table.new("test")] }
        let(:tables_b) { [DD::Table.new("test")] }

        it "returns an empty array" do
          expect(subject).to eq []
        end
      end

      context "with tables a and b in database a, tables a and c in the database b" do
        let(:tables_a) { [DD::Table.new("a"), DD::Table.new("b")] }
        let(:tables_b) { [DD::Table.new("a"), DD::Table.new("c")] }

        it "returns a diff for table b" do
          expect(subject.length).to eq 2
          diff_b = subject.find { |d| d.table == "b" }
          expect(diff_b.description).to eq "Table 'b' found in 1 database, but not in 1 other database"
          expect(diff_b.databases_found).to eq [database_a]
          expect(diff_b.databases_not_found).to eq [database_b]
        end

        it "returns a diff for table c" do
          diff_c = subject.find { |d| d.table == "c" }
          expect(diff_c.description).to eq "Table 'c' found in 1 database, but not in 1 other database"
          expect(diff_c.databases_found).to eq [database_b]
          expect(diff_c.databases_not_found).to eq [database_a]
        end
      end
    end

    context "with 5 databases" do
      let(:databases) { %w[a b c d e].map { |name| DD::Database.new("fake_db_engine", name: name) } }
      let(:common_table) { DD::Table.new("common") }
      let(:table_a) { DD::Table.new("a") }
      let(:table_b) { DD::Table.new("b") }
      before do
        databases.each { |db| db.add_table common_table.dup }
        databases[0..2].each { |db| db.add_table table_a.dup }
        databases[2..3].each { |db| db.add_table table_b.dup }
      end

      it "does not return a diff for common table" do
        common_diff = subject.find { |d| d.table == "common" }
        expect(common_diff).to be nil
      end

      it "returns a diff for table a" do
        diff_a = subject.find { |d| d.table == "a" }
        expect(diff_a.description).to eq "Table 'a' found in 3 databases, but not in 2 other databases"
        expect(diff_a.databases_found).to eq databases[0..2]
        expect(diff_a.databases_not_found).to eq databases[3..4]
      end

      it "returns a diff for table b" do
        diff_b = subject.find { |d| d.table == "b" }
        expect(diff_b.description).to eq "Table 'b' not found in 3 databases, but found in 2 other databases"
        expect(diff_b.databases_found).to eq databases[2..3]
        expect(diff_b.databases_not_found).to eq [databases[0], databases[1], databases[4]]
      end
    end
  end
end
