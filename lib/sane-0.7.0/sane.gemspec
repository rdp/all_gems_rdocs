# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sane}
  s.version = "0.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Roger Pack"]
  s.date = %q{2009-10-23}
  s.description = %q{Helper methods for ruby to make it easier to work with out of the box--things that are missing from core but should be there}
  s.email = ["rogerdpack@gmail.com"]
  s.extra_rdoc_files = [
    "ChangeLog",
     "README"
  ]
  s.files = [
    "ChangeLog",
     "README",
     "Rakefile",
     "VERSION",
     "lib/_dbg.rb",
     "lib/sane.rb",
     "lib/sane_ruby/add_regexes.rb",
     "lib/sane_ruby/bugs.rb",
     "lib/sane_ruby/enumerable-extra.rb",
     "lib/sane_ruby/enumerable_brackets.rb",
     "lib/sane_ruby/hash_hashes.rb",
     "lib/sane_ruby/irb_startup_options.rb",
     "lib/sane_ruby/sane_random.rb",
     "sane.gemspec",
     "spec/test_sane.spec",
     "todo"
  ]
  s.homepage = %q{http://github.com/rogerdpack/sane_ruby}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Helper methods for ruby to make it easier to work with out of the box--things that are missing from core but should be there}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<require_all>, [">= 0"])
      s.add_runtime_dependency(%q<backports>, [">= 0"])
      s.add_runtime_dependency(%q<hash_set_operators>, [">= 0"])
    else
      s.add_dependency(%q<require_all>, [">= 0"])
      s.add_dependency(%q<backports>, [">= 0"])
      s.add_dependency(%q<hash_set_operators>, [">= 0"])
    end
  else
    s.add_dependency(%q<require_all>, [">= 0"])
    s.add_dependency(%q<backports>, [">= 0"])
    s.add_dependency(%q<hash_set_operators>, [">= 0"])
  end
end
