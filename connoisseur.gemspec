Gem::Specification.new do |s|
  s.name     = "connoisseur"
  s.version  = "1.7.0"
  s.authors  = "George Claghorn"
  s.email    = "georgeclaghorn@gmail.com"
  s.summary  = "Client for the Akismet spam filtering service"
  s.homepage = "https://github.com/georgeclaghorn/connoisseur"
  s.license  = "MIT"

  s.required_ruby_version = ">= 2.4.0"

  s.add_development_dependency "rake",     "~> 12.0"
  s.add_development_dependency "minitest", "~> 5.11"
  s.add_development_dependency "webmock",  "~> 3.0"
  s.add_development_dependency "byebug",   "~> 9.1"

  s.files      = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- test/*`.split("\n")
end
