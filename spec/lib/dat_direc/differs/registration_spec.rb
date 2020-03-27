require "dat_direc/differs/registration"

RSpec.describe DatDirec::Differs do
  describe ".register" do
    around do |example|
      old_value = described_class.differs.dup
      described_class.remove_instance_variable(:@differs)
      example.run
      described_class.instance_variable_set(:@differs, old_value)
    end

    before do
      described_class.instance_variable_set(:@differs, differs)
    end

    context "when differs is empty" do
      let(:differs) { [] }
    end
  end
end
