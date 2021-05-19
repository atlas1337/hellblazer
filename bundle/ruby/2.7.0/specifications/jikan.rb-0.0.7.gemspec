# -*- encoding: utf-8 -*-
# stub: jikan.rb 0.0.7 ruby lib

Gem::Specification.new do |s|
  s.name = "jikan.rb".freeze
  s.version = "0.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Zerocchi".freeze]
  s.bindir = "exe".freeze
  s.date = "2019-03-07"
  s.description = "This is a wrapper for unofficial MyAnimeList API, Jikan.me. \n                        Consult Jikan.me documentation to learn more. ".freeze
  s.email = ["slaveration@gmail.com".freeze]
  s.homepage = "https://github.com/Zerocchi/jikan.rb".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "A simple Ruby wrapper for jikan.me API.".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<http>.freeze, ["~> 3.0.0"])
    s.add_runtime_dependency(%q<require_all>.freeze, ["~> 2.0.0"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.16"])
    s.add_development_dependency(%q<pry>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_development_dependency(%q<vcr>.freeze, [">= 0"])
    s.add_development_dependency(%q<webmock>.freeze, [">= 0"])
  else
    s.add_dependency(%q<http>.freeze, ["~> 3.0.0"])
    s.add_dependency(%q<require_all>.freeze, ["~> 2.0.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.16"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<vcr>.freeze, [">= 0"])
    s.add_dependency(%q<webmock>.freeze, [">= 0"])
  end
end
