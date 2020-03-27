# frozen_string_literal: true

require "dat_direc/core/database"
require "dat_direc/core/table"
require "dat_direc/core/column"
require "dat_direc/dump_parsers/mysql"

RSpec.describe DatDirec::DumpParsers::MySQL do
  subject { described_class.new(io).parse }

  let(:io) { StringIO.new(_sql) }
  let(:_sql) { sql }

  context "with a single table" do
    let(:sql) do
      <<~SQL
        CREATE TABLE `creams` (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `name` varchar(255) NOT NULL DEFAULT '',
          `consistency` float(11,4) NOT NULL,
          `simple` text,
          `test` int
        ) ENGINE=InnoDB;
      SQL
    end

    let(:expected) { DD::Database.new(:mysql, tables: [creams]) }
    let(:creams) { DD::Table.new("creams", columns: creams_columns) }
    let(:creams_columns) { [
      DD::Column.new("id", "int", limit: 11, null: false, auto_increment: true),
      DD::Column.new("name", "string", limit: 255, null: false, default: ""),
      DD::Column.new("consistency", "float", limit: 11, decimal: 4, null: false),
      DD::Column.new("simple", "text"),
      DD::Column.new("test", "int")
    ] }

    it "correctly parses the database" do
      res = subject
      expect(res).to eq expected
    end
  end

  describe ".detect" do
    subject { described_class.detect(io) }

    context "when SQL first line contains MySQL" do
      let(:sql) { "-- hello from MySQL!\nSECOND LINE" }

      it { is_expected.to be_truthy }

      it "io rewinds" do
        subject
        expect(io.gets).to eq "-- hello from MySQL!\n"
      end
    end

    context "when SQL first line doesn't contains MySQL" do
      let(:sql) { "-- hello from postgres!\nSECOND LINE" }

      it { is_expected.to be_falsey }

      it "io doesn't move on to the second line" do
        subject
        expect(io.gets).to eq "-- hello from postgres!\n"
      end
    end

    context "when file is empty" do
      let(:sql) { "" }

      it { is_expected.to be_falsey }
    end
  end
end
