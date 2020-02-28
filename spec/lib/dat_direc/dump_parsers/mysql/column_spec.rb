# frozen_string_literal: true

require "dat_direc/dump_parsers/mysql/column"

describe DatDirec::DumpParsers::MySQL::Column do
  subject { described_class.new(line + extras, line_no).parse }
  let(:line_no) { 1 }
  let(:extras) { " " + [collate, null, default, auto_increment].compact.join(" ") + "," }
  let(:collate) { nil }
  let(:null) { nil }
  let(:default) { nil }
  let(:auto_increment) { nil }

  shared_examples_for "collatable" do
    context "with COLLATE utf8_unicode_ci" do
      let(:collate) { "COLLATE utf8_unicode_ci" }

      it "has collate: 'utf8_unicode_ci' in options" do
        expect(subject.options[:collate]).to eq "utf8_unicode_ci"
      end
    end

    context "with COLLATE utf8mb4_unicode_ci" do
      let(:collate) { "COLLATE utf8mb4_unicode_ci" }

      it "has collate: 'utf8mb4_unicode_ci' in options" do
        expect(subject.options[:collate]).to eq "utf8mb4_unicode_ci"
      end
    end

    context "without COLLATE" do
      it "has not got collate in options" do
        expect(subject.options.key?(:collate)).to be false
      end
    end
  end

  shared_examples_for "nullable" do
    context "with NULL" do
      let(:null) { "NULL" }

      it "has null: true in options" do
        expect(subject.options[:null]).to be true
      end

      include_examples "collatable"
    end

    context "with NOT NULL" do
      let(:null) { "NOT NULL" }

      it "has null: false in options" do
        expect(subject.options[:null]).to be false
      end
      include_examples "collatable"
    end

    context "without NULL" do
      it "has not got null in options" do
        expect(subject.options.key?(:null)).to be false
      end

      include_examples "collatable"
    end
  end

  shared_examples_for "defaultable" do
    context "with DEFAULT '1'" do
      let(:default) { "DEFAULT '1'" }

      it "has default: '1' in options" do
        expect(subject.options[:default]).to eq "1"
      end

      include_examples "nullable"
    end

    context "with DEFAULT NULL" do
      let(:default) { "DEFAULT NULL" }

      it "has default: null in options" do
        expect(subject.options.key?(:default)).to be true
        expect(subject.options[:default]).to be nil
      end
      include_examples "nullable"
    end

    context "without DEFAULT" do
      it "has not got default in options" do
        expect(subject.options.key?(:default)).to be false
      end

      include_examples "nullable"
    end
  end

  shared_examples_for "auto_incrementable" do
    context "with AUTO_INCREMENT" do
      let(:auto_increment) { "AUTO_INCREMENT" }

      it "has got auto_increment: true in options" do
        expect(subject.options[:auto_increment]).to be true
      end
      include_examples "defaultable"
    end

    context "without AUTO_INCREMENT" do
      it "hasn't got auto_increment in options" do
        expect(subject.options.key?(:auto_increment)).to be false
      end
      include_examples "defaultable"
    end
  end

  shared_examples_for "options" do
    include_examples "auto_incrementable"
  end

  shared_examples_for "column" do |name:, type: |
    generic_type = described_class.generic_type(type)
    include_examples "options"

    it "has type '#{generic_type}'" do
      expect(subject.type).to eq generic_type
    end

    it "has name '#{name}'" do
      expect(subject.name).to eq name
    end
  end

  shared_examples_for "column with one limit" do |name:, type:|
    include_examples "column", name: name, type: type

    it "has nil limit" do
      expect(subject.options[:limit]).to be nil
    end

    context "with length 255" do
      let(:line) { "`id` #{type}(255)" }
      generic_type = described_class.generic_type(type)

      it "has id for a name and #{generic_type} for type" do
        expect(subject.name).to eq "id"
        expect(subject.type).to eq generic_type
      end

      it "has limit: 255 in options" do
        expect(subject.options[:limit]).to eq 255
      end

      include_examples "options"
    end
  end

  shared_examples_for "column with two type params" do |name:, type:|
    # the two-limit columns can also take just one limit
    include_examples "column with one limit", name: name, type: type

    context "with (11,4)" do
      let(:line) { "`id` #{type}(11,4)" }

      generic_type = described_class.generic_type(type)

      it "has id for a name and #{generic_type} for type" do
        expect(subject.name).to eq "id"
        expect(subject.type).to eq generic_type
      end

      it "has limit: 11 in options" do
        expect(subject.options[:limit]).to eq 11
      end

      it "has decimal: 4 in options" do
        expect(subject.options[:decimal]).to eq 4
      end

      include_examples "options"
    end
  end

  %w[
    date
    time
    datetime
    timestamp
    year
    tinyblob
    blob
    mediumblob
    bigblob
    tinytext
    text
    mediumtext
    bigtext
  ].each do |type|
    context "with a #{type} column called 'id'" do
      let(:line) { "`id` #{type}" }

      it_behaves_like "column", name: "id", type: type
    end

    context "with a #{type} column called 'message'" do
      let(:line) { "`message` #{type}" }

      it_behaves_like "column", name: "message", type: type
    end
  end

  %w[
    varchar
    char
    int
    tinyint
    smallint
  ].each do |type|
    context "with a #{type} column called 'id'" do
      let(:line) { "`id` #{type}" }

      it_behaves_like "column with one limit", name: "id", type: type
    end

    context "with a #{type} column called 'message'" do
      let(:line) { "`message` #{type}" }

      it_behaves_like "column with one limit", name: "message", type: type
    end
  end

  two_number_types = %w[
      float
      double
      decimal
  ].each do |type|
    context "with a #{type} column called 'id'" do
      let(:line) { "`id` #{type}" }

      it_behaves_like "column with two type params", name: "id", type: type
    end

    context "with a #{type} column called 'message'" do
      let(:line) { "`message` #{type}" }

      it_behaves_like "column with two type params", name: "message", type: type
    end
  end
end
