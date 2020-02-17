# frozen_string_literal: true

require "dat_direc/dump_parsers/mysql/key"

RSpec.describe DatDirec::DumpParsers::MySQL::Key do
  subject { described_class.new(line, line_no).parse }
  let(:line_no) { 1 }

  context "with a PRIMARY KEY" do
    let(:line) { "PRIMARY KEY (`id`)" }

    it "returns an primary Index" do
      idx = subject
      expect(idx.name).to eq("")
      expect(idx.type).to eq("primary")
      expect(idx.columns).to eq(%w[id])
    end

    context "with multiple columns" do
      # idk it was the first semi-real example I could think of
      let(:line) { "PRIMARY KEY (`postcode`,`house_number`)" }

      it "returns an primary Index" do
        idx = subject
        expect(idx.name).to eq("")
        expect(idx.type).to eq("primary")
        expect(idx.columns).to eq(%w[postcode house_number])
      end
    end
  end

  context "with a named KEY" do
    let(:line) { "KEY `by_user_id` (`user_id`)" }

    it "returns an index" do
      idx = subject
      expect(idx.name).to eq("by_user_id")
      expect(idx.type).to eq("index")
      expect(idx.columns).to eq(%w[user_id])
    end

    context "with multiple columns" do
      let(:line) { "KEY `by_address` (`postcode`,`house_number`)" }

      it "returns an primary Index" do
        idx = subject
        expect(idx.name).to eq("by_address")
        expect(idx.type).to eq("index")
        expect(idx.columns).to eq(%w[postcode house_number])
      end
    end
  end

  context "with a UNIQUE KEY" do
    let(:line) { "UNIQUE KEY `by_user_id` (`user_id`)" }

    it "returns an index" do
      idx = subject
      expect(idx.name).to eq("by_user_id")
      expect(idx.type).to eq("unique")
      expect(idx.columns).to eq(%w[user_id])
    end

    context "with multiple columns" do
      let(:line) { "UNIQUE KEY `by_address` (`postcode`,`house_number`)" }

      it "returns an primary Index" do
        idx = subject
        expect(idx.name).to eq("by_address")
        expect(idx.type).to eq("unique")
        expect(idx.columns).to eq(%w[postcode house_number])
      end
    end
  end
end
