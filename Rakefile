require 'hoe'
require './lib/beerdb/version.rb'


Hoe.spec 'beerdb' do
  
  self.version = BeerDb::VERSION
  
  self.summary = 'beerdb - beer.db command line tool'
  self.description = summary

  self.urls    = ['https://github.com/geraldb/beer.db.ruby']
  
  self.author  = 'Gerald Bauer'
  self.email   = 'beerdb@googlegroups.com'
    
  # switch extension to .markdown for gihub formatting
  self.readme_file  = 'README.md'
  self.history_file = 'History.md'
  
  self.extra_deps = [
    ['activerecord', '~> 3.2'],  # NB: will include activesupport,etc.
    ### ['sqlite3',      '~> 1.3']  # NB: install on your own; remove dependency

    ['worlddb', '~> 1.7'],  # NB: worlddb already includes
                               #         - logutils
                               #         - textutils
                               
     ## 3rd party
    ['gli', '>= 2.5.6']
  ]

  self.licenses = ['Public Domain']

  self.spec_extras = {
   :required_ruby_version => '>= 1.9.2'
  }

end

