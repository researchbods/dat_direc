# frozen_string_literal: true

Gem::Specification.new do |s|
  s.required_ruby_version = ">= 2.3.3"
  s.name = "dat_direc"
  s.version = "0.0.1"
  s.authors = ["Telyn Roat"]
  s.email = ["troat@researchbods.com"]
  s.homepage = ""
  s.summary = <<-SUMMARY
    Database Difference Reconciler:

    Checks a collection of SQL structures for inconsistencies and generates
    migrations to reconcile those inconsistencies
  SUMMARY

  s.description = s.summary
  s.license = "MIT"

  s.add_dependency "terminal-table", "~> 1.8"
  s.add_dependency "thor", "~> 1.0"

  s.add_development_dependency "fuubar", "~> 2.3"
  s.add_development_dependency "guard", "~> 2.15"
  s.add_development_dependency "guard-rspec", "~> 4.7"
  s.add_development_dependency "guard-rubocop", "~> 1.3"
  s.add_development_dependency "mutant-rspec", "~> 0.9.5"
  s.add_development_dependency "rspec", "~> 3.8"
  s.add_development_dependency "rubocop", "~> 0.79"
  # 0.18 incompatible with codeclimate for now
  s.add_development_dependency "simplecov", "< 0.18"

  s.files = Dir[
    "lib/**/*",
    "bin/*",
    "README.md",
  ]

  s.executables = %w[datdirec]
end
