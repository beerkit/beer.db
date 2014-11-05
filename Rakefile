require 'hoe'
require './lib/beerdb/version.rb'


Hoe.spec 'beerdb' do
  
  self.version = BeerDb::VERSION
  
  self.summary = 'beerdb - beer.db command line tool'
  self.description = summary

  self.urls    = ['https://github.com/beerkit/beer.db.ruby']

  self.author  = 'Gerald Bauer'
  self.email   = 'beerdb@googlegroups.com'

  # switch extension to .markdown for gihub formatting
  self.readme_file  = 'README.md'
  self.history_file = 'History.md'

  self.extra_deps = [
    ['props' ],
    ['logutils'],
    ['textutils'],
    ['worlddb', '>= 2.0.2'],  # NB: worlddb already includes
                               #         - logutils
                               #         - textutils
    ['tagutils'],     # tags n tagging tables
    ['activerecord-utils'],   # extras e.g. rnd, find_by! for 3.x etc.
    ['fetcher', '>= 0.3'],

    ## 3rd party
    ['gli', '>= 2.5.6'],

    ['rubyzip'],   ## NOTE: used for ZipReader (optional in textutils, thus, pull it in here)

    ['activerecord']  # NB: will include activesupport,etc.
    ### ['sqlite3',      '~> 1.3']  # NB: install on your own; remove dependency
  ]

  self.licenses = ['Public Domain']

  self.spec_extras = {
   :required_ruby_version => '>= 1.9.2'
  }

end
