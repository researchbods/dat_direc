# frozen_string_literal: true

require "dat_direc/core/column"

RSpec.describe DatDirec::Column do
  subject(:column) { described_class.new(name, type, **options) }

  describe "#==" do
    subject { column == other }
    let(:name) { "steven" }
    let(:type) { "string" }
    let(:options) { { limit: 4, null: true, default: "139" } }
    let(:other) { described_class.new(other_name, other_type, **other_options) }
    let(:other_name) { name }
    let(:other_type) { type }
    let(:other_options) { options }

    context "when comparing two identical columns" do
      it { is_expected.to be true }
    end

    context "when names differ" do
      let(:other_name) { "Jeffrey" }

      it { is_expected.to be false }
    end

    context "when types differ" do
      let(:other_type) { "int" }
      it { is_expected.to be false }
    end

    context "when an option is missing" do
      let(:other_options) { options.dup }

      before { other_options.delete(:limit) }
      it { is_expected.to be false }
    end
  end
end
