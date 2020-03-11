# frozen_string_literal: true

require "dat_direc/dump_parsers"

class FakeParser
  def self.detect(io)
    res = io.gets.include?("Parser One")
    io.rewind
    res
  end
end

class FakeParser2
  def self.detect(io)
    res = io.gets.include?("Parser Two")
    io.rewind
    res
  end
end

RSpec.describe DatDirec::DumpParsers do
  describe ".register_parser" do
    subject { described_class.register_parser(parser) }

    around do |example|
      old_value = described_class.parsers.dup
      described_class.remove_instance_variable(:@parsers)
      example.run
      described_class.instance_variable_set(:@parsers, old_value)
    end

    context "when given a non-class object" do
      let(:parser) { 0 }
      it "raises ArgumentError" do
        expect { subject }.to raise_error(ArgumentError)
      end

      it "does not change .parsers" do
        expect {
          begin
            subject
          rescue ArgumentError
            nil
          end
        }.not_to change { described_class.parsers }
      end
    end

    context "when given a class object" do
      let(:parser) { FakeParser }

      it "adds the parser" do
        expect { subject }.to change { described_class.parsers.to_a }.to([FakeParser])
      end

      context "when there's already a parser" do
        before { described_class.register_parser(FakeParser2) }

        it "adds the parser" do
          expect { subject }.to(
            change { described_class.parsers.to_a }
            .to([FakeParser2, FakeParser])
          )
        end
      end

      context "when the parser is already added" do
        before { described_class.register_parser(FakeParser) }

        it "doesn't add the parser" do
          expect { subject }.not_to change { described_class.parsers.to_a }
        end
      end
    end
  end

  describe "#find_parser" do
    subject { described_class.find_parser(io) }
    let(:io) { StringIO.new(str) }

    context "when @parsers is stubbed out" do
      around do |example|
        old_value = described_class.parsers.dup
        described_class.remove_instance_variable(:@parsers)
        example.run
        described_class.instance_variable_set(:@parsers, old_value)
      end

      before { described_class.instance_variable_set(:@parsers, parsers) }
      let(:parsers) { Set.new([FakeParser, FakeParser2]) }

      context "with io whose first line contains Parser One" do
        let(:str) { "Parser One\n" }

        it { is_expected.to eq FakeParser }
      end

      context "with io whose first line contains Parser Two" do
        let(:str) { "Parser Two\n" }

        it { is_expected.to eq FakeParser2 }
      end

      context "with io whose first line contains neither Parser One nor Parser Two" do
        let(:str) { "Hey i'm jeff\nParser Two\n" }

        it { is_expected.to be nil }
      end
    end

    context "in real life" do
      context "with io whose first line contains MySQL" do
        let(:str) { "-- MySQL dump 11.5  Distrib 8.1.01, for Linux (x86_64)\n" }

        it { is_expected.to eq DatDirec::DumpParsers::MySQL }
      end
    end
  end
end
