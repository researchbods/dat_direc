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

  context "with an int column" do
    let(:line) { "`id` int" }
    # include_examples "options"
    it "has id for a name and int for type" do
      expect(subject.name).to eq "id"
      expect(subject.type).to eq "int"
    end

    context "with length 11" do
      let(:line) { "`id` int(11)" }

      it "has id for a name and int for type" do
        expect(subject.name).to eq "id"
        expect(subject.type).to eq "int"
      end

      it "has limit: 11 in options" do
        expect(subject.options[:limit]).to eq 11
      end

      include_examples "options"
    end
  end
end
