# frozen_string_literal: true

require "dat_direc/differs/registration"

class FakeDiffer
  def self.priority
    1
  end

  def diff(databases); end
end

class FakeDiffer2
  def self.priority
    0
  end

  def diff(databases); end
end

RSpec.describe DatDirec::Differs do
  describe ".register" do
    subject { described_class.register(differ) }

    around do |example|
      old_value = described_class.send(:differs).dup
      described_class.remove_instance_variable(:@differs)
      example.run
      described_class.instance_variable_set(:@differs, old_value)
    end

    before do
      described_class.instance_variable_set(:@differs, Set.new(differs))
    end

    shared_examples_for "does not add bad differ" do
      context "when attempting to regiser something that isn't a differ" do
        let(:differ) { 10 }

        it "raises an error" do
          expect { subject }.to raise_error(DD::Differs::BadDifferError)
        end

        it "does not change differs" do
          expect { subject rescue nil }.not_to change { DD::Differs.send(:differs) }
        end
      end
    end

    context "when differs is empty" do
      let(:differs) { [] }

      context "when attempting to register FakeDiffer" do
        let(:differ) { FakeDiffer }
        it "adds FakeDiffer to differs" do
          expect { subject }.to change { DD::Differs.send(:differs) }.to [FakeDiffer]
        end
      end

      context "when attempting to register FakeDiffer2" do
        let(:differ) { FakeDiffer2 }

        it "adds FakeDiffer to differs" do
          expect { subject }.to change { DD::Differs.send(:differs) }.to [FakeDiffer2]
        end
      end

      it_behaves_like "does not add bad differ"
    end

    context "when differs has FakeDiffer" do
      let(:differs) { [FakeDiffer] }

      context "when attempting to register FakeDiffer" do
        let(:differ) { FakeDiffer }

        it "does nothing" do
          expect { subject }.not_to change { DD::Differs.send(:differs) }
        end
      end

      context "when attempting to register FakeDiffer2" do
        let(:differ) { FakeDiffer2 }

        it "adds FakeDiffer2 to differs" do
          expect { subject }.to change { DD::Differs.send(:differs) }.to Set.new([FakeDiffer, FakeDiffer2])
        end
      end

      it_behaves_like "does not add bad differ"
    end

    context "when differs has FakeDiffer2" do
      let(:differs) { [FakeDiffer2] }

      context "when attempting to register FakeDiffer" do
        let(:differ) { FakeDiffer }

        it "adds FakeDiffer to differs" do
          expect { subject }.to change { DD::Differs.send(:differs) }.to Set.new([FakeDiffer, FakeDiffer2])
        end
      end

      context "when attempting to register FakeDiffer2" do
        let(:differ) { FakeDiffer2 }

        it "does nothing" do
          expect { subject }.not_to change { DD::Differs.send(:differs) }
        end
      end

      it_behaves_like "does not add bad differ"
    end
  end
end

RSpec.describe DD::Differs::BadDifferError do
  subject { described_class.new(differ) }

  context "when differ is not a class" do
    let(:differ) { 10 }

  end

  context "when differ does not implement priority" do
    let(:differ) { Struct.new(:diff) }

  end
end
