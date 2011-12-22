Gem::Specification.new do |s|
  s.name = "stinger"
  s.version = `cat VERSION`.strip
  s.required_rubygems_version = ">= 1.3.6"
  s.authors = [%q{Daniel Greenlaw}]
  s.homepage = "https://github.com/pungerfreak/stinger"
  s.summary = "API wrapper for Blue Hornet EMS."
  s.description = "Stinger provides an easy to use API wrapper for interaction with Blue Hornet's Email Marketing Service API."
  s.email = "git@danielgreenlaw.com"

  s.files = [
    "VERSION",
    "stinger.gemspec",
    "init.rb",
    "lib/api.rb",
    "rails/init.rb"
  ]
  s.require_path = "lib"
end
