# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "grouped_validations/version"

Gem::Specification.new do |s|
  s.name        = %q{grouped_validations}
  s.version     = GroupedValidations::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Adam Meehan"]
  s.email       = %q{adam.meehan@gmail.com}
  s.homepage    = %q{http://github.com/adzap/grouped_validations}
  s.summary     = %q{Define validation groups in a model for greater control over which validations are run.}
  s.description = s.summary

  s.rubyforge_project = %q{grouped_validations}

  s.files            = `git ls-files`.split("\n") - %w{ .gitignore .rspec autotest }
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.extra_rdoc_files = ["README.rdoc"]
  s.require_paths    = ["lib"]
  s.autorequire      = %q{grouped_validations}
end
