# frozen_string_literal: true

require "dat_direc/dump_parsers"

class FakeParser
end
class FakeParser2
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

        fit "adds the parser" do
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
end
