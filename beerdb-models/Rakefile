require 'hoe'
require './lib/beerdb/version.rb'


Hoe.spec 'beerdb-models' do
  
  self.version = BeerDb::VERSION
  
  self.summary = "beerdb-models - beer.db schema 'n' models for easy (re)use"
  self.description = summary

  self.urls    = ['https://github.com/beerkit/beer.db.models']

  self.author  = 'Gerald Bauer'
  self.email   = 'beerdb@googlegroups.com'

  # switch extension to .markdown for gihub formatting
  self.readme_file  = 'README.md'
  self.history_file = 'HISTORY.md'

  self.extra_deps = [
    ['worlddb-models', '>= 2.2.0'],  # Note: worlddb-models pulls in all dependencies
  ]

  self.licenses = ['Public Domain']

  self.spec_extras = {
    required_ruby_version: '>= 1.9.2'
  }

end
