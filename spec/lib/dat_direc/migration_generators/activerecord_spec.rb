require "support/migration_generator_examples"
require "dat_direc/migration_generators/activerecord"

RSpec.describe DD::MigrationGenerators::ActiveRecord do
  it_behaves_like "a migration generator"

  describe "#generate_up" do
    context "when passed a CreateTable" do
      it "calls CreateTable" do
      end
    end
  end
end
