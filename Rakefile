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

    ['worlddb', '~> 1.6'],  # NB: worlddb already includes
                               #         - commander
                               #         - logutils
                               #         - textutils
                               
  ## 3rd party
    ['commander', '~> 4.1.3']   # remove? -- already included as dep in worlddb                               
  ]

 self.licenses = ['Public Domain']

  self.spec_extras = {
   :required_ruby_version => '>= 1.9.2'
  }

end



##############################
## for testing 
##
## NB: use rake -I ../world.db.ruby/lib -I ./lib beerdb:build

namespace :beerdb do
  
  BUILD_DIR = "./build"
  
  BEER_DB_PATH = "#{BUILD_DIR}/beer.db"

  DB_CONFIG = {
    :adapter   =>  'sqlite3',
    :database  =>  BEER_DB_PATH
  }

  directory BUILD_DIR

  task :clean do
    rm BEER_DB_PATH if File.exists?( BEER_DB_PATH )
  end

  task :env => BUILD_DIR do
    require 'worlddb'   ### NB: for local testing use rake -I ./lib dev:test e.g. do NOT forget to add -I ./lib
    require 'beerdb'
    require 'logutils/db'

    LogUtils::Logger.root.level = :debug

    pp DB_CONFIG
    ActiveRecord::Base.establish_connection( DB_CONFIG )
  end

  task :create => :env do
    LogDb.create
    WorldDb.create
    BeerDb.create
  end

  task :importworld => :env do
    WorldDb.read_setup( 'setups/sport.db.admin', '../world.db', skip_tags: true )  # populate world tables
    WorldDb.tables
  end

  task :importbeer => :env do
    BeerDb.read_setup( 'setups/at', '../beer.db' )
    BeerDb.tables
  end

  task :deletebeer => :env do
    BeerDb.delete!
  end


  desc 'beerdb - build from scratch'
  task :build => [:clean, :create, :importworld, :importbeer] do
    puts 'Done.'
  end

  desc 'beerdb - update'
  task :update => [:deletebeer, :importbeer] do
    puts 'Done.'
  end

end  # namespace :beerdb
