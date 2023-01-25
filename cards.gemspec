$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cards/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cards"
  s.version     = Cards::VERSION
  s.authors     = ["Alexander Rjazantsev", "Vladimir Vorona", "Gregory Kravchenko"]
  s.email       = ["ar@anahoret.com", "vvo@anahoret.com", "gpk@anahoret.com"]
  s.homepage    = "http://gitlab.anahoret.com/anadea/cards"
  s.summary     = "Anadea's wiki engine."
  s.description = "This wiki-engine which is extracted for Anadea's Tracker."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency 'activerecord', '>= 4.0'
  s.add_dependency 'protected_attributes'
  s.add_dependency 'paperclip', '~> 4.1'
  s.add_dependency 'squeel'

  s.add_development_dependency "bundler", "~> 1.7"
  s.add_development_dependency "rake", "~> 10.0"
end
