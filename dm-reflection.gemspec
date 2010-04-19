# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-reflection}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Martin Gamsjaeger (snusnu), Yogo Team"]
  s.date = %q{2010-04-19}
  s.description = %q{Generates datamapper models from existing database schemas and export them to files}
  s.email = %q{irjudson@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "dm-reflection.gemspec",
     "lib/dm-reflection.rb",
     "lib/dm-reflection/adapters/mysql.rb",
     "lib/dm-reflection/adapters/persevere.rb",
     "lib/dm-reflection/adapters/postgres.rb",
     "lib/dm-reflection/adapters/sqlite3.rb",
     "lib/dm-reflection/builders/source_builder.rb",
     "lib/dm-reflection/reflection.rb",
     "lib/dm-reflection/version.rb",
     "spec/persevere_reflection_spec.rb",
     "spec/rcov.opts",
     "spec/reflection_spec.rb",
     "spec/source_builder_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "tasks/changelog.rake",
     "tasks/ci.rake",
     "tasks/metrics.rake",
     "tasks/spec.rake",
     "tasks/yard.rake",
     "tasks/yardstick.rake"
  ]
  s.homepage = %q{http://github.com/irjudson/dm-reflection}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Generates datamapper models from existing database schemas}
  s.test_files = [
    "spec/mock_persevere_adapter.rb",
     "spec/persevere_reflection_spec.rb",
     "spec/reflection_spec.rb",
     "spec/source_builder_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dm-core>, ["~> 0.10.2"])
      s.add_development_dependency(%q<rspec>, ["~> 1.3"])
      s.add_development_dependency(%q<yard>, ["~> 0.5"])
    else
      s.add_dependency(%q<dm-core>, ["~> 0.10.2"])
      s.add_dependency(%q<rspec>, ["~> 1.3"])
      s.add_dependency(%q<yard>, ["~> 0.5"])
    end
  else
    s.add_dependency(%q<dm-core>, ["~> 0.10.2"])
    s.add_dependency(%q<rspec>, ["~> 1.3"])
    s.add_dependency(%q<yard>, ["~> 0.5"])
  end
end

