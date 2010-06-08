# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{grouped_validations}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Adam Meehan"]
  s.autorequire = %q{grouped_validations}
  s.date = %q{2010-06-08}
  s.description = %q{Define validation groups in ActiveRecord for greater control over which validations to run.}
  s.email = %q{adam.meehan@gmail.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["MIT-LICENSE", "README.rdoc", "Rakefile", "lib/grouped_validations", "lib/grouped_validations/active_model.rb", "lib/grouped_validations/active_record.rb", "lib/grouped_validations/version.rb", "lib/grouped_validations.rb", "spec/grouped_validations_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/adzap/grouped_validations}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{grouped_validations}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Define validation groups in ActiveRecord for greater control over which validations to run.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
