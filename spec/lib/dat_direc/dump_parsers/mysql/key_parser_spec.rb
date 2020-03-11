# frozen_string_literal: true

require "dat_direc/dump_parsers/mysql/key_parser"

RSpec.describe DatDirec::DumpParsers::MySQL::KeyParser do
  subject { described_class.new(line, line_no).parse }
  let(:line_no) { 1 }
  let(:line) { "#{sql_type} #{_sql_name}#{sql_columns}" }
  let(:_sql_name) { sql_name ? sql_name + " " : sql_name }

  shared_examples_for "returns matching index" do
    it "returns the correct name and type" do
      expect(subject.name).to eq expected_name
      expect(subject.type).to eq expected_type
    end

    it "returns the correct columns" do
      expect(subject.columns).to eq expected_columns
    end

    it "returns the correct options" do
      expect(subject.options).to eq expected_options
    end
  end

  shared_examples_for "parses correctly" do
    context "with one column" do
      let(:sql_columns) { "(`id`)" }
      let(:expected_columns) { %w[id] }
      let(:expected_options) { {} }

      include_examples "returns matching index"

      context "with a limit" do
        let(:sql_columns) { "(`id`(128))" }
        let(:expected_options) { { length: { "id" => 128 } } }

        include_examples "returns matching index"
      end
    end

    context "with multiple columns" do
      let(:sql_columns) { "(`postcode`,`house_number`)" }
      let(:expected_columns) { %w[postcode house_number] }
      let(:expected_options) { {} }

      include_examples "returns matching index"

      context "with a limit on the first column" do
        let(:sql_columns) { "(`postcode`(16),`house_number`)" }
        let(:expected_options) { { length: { "postcode" => 16 } } }

        include_examples "returns matching index"
      end

      context "with a limit on the second column" do
        let(:sql_columns) { "(`postcode`,`house_number`(12))" }
        let(:expected_options) { { length: { "house_number" => 12 } } }

        include_examples "returns matching index"
      end
    end
  end

  context "with a PRIMARY KEY" do
    let(:sql_type) { "PRIMARY KEY" }
    let(:expected_type) { "primary" }
    let(:columns) { %w[id] }
    let(:expected_name) { "" }
    let(:sql_name) { nil }

    it_behaves_like "parses correctly"
  end

  context "with a KEY" do
    let(:sql_type) { "KEY" }
    let(:expected_type) { "index" }
    let(:expected_name) { "sam_the_index" }
    let(:sql_name) { "`sam_the_index`" }

    it_behaves_like "parses correctly"
  end

  context "with a UNIQUE KEY" do
    let(:sql_type) { "UNIQUE KEY" }
    let(:expected_type) { "unique" }
    let(:expected_name) { "idris_the_index" }
    let(:sql_name) { "`idris_the_index`" }

    it_behaves_like "parses correctly"
  end
end
