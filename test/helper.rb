
## $:.unshift(File.dirname(__FILE__))

## minitest setup

# require 'minitest/unit'
require 'minitest/autorun'

# include MiniTest::Unit  # lets us use TestCase instead of MiniTest::Unit::TestCase


# ruby stdlibs

require 'json'
require 'uri'
require 'pp'

# ruby gems

require 'active_record'

# our own code

require 'beerdb'
require 'logutils/db'   # NB: explict require required for LogDb (not automatic) 

Country = WorldDb::Models::Country

## todo: get all models aliases (e.g. from console script)

Beer    = BeerDb::Models::Beer
Brand   = BeerDb::Models::Brand
Brewery = BeerDb::Models::Brewery


def setup_in_memory_db
  # Database Setup & Config

  db_config = {
    adapter:  'sqlite3',
    database: ':memory:'
  }

  pp db_config

  ActiveRecord::Base.logger = Logger.new( STDOUT )
  ## ActiveRecord::Base.colorize_logging = false  - no longer exists - check new api/config setting?

  ## NB: every connect will create a new empty in memory db
  ActiveRecord::Base.establish_connection( db_config )


  ## build schema

  LogDb.create
  WorldDb.create
  BeerDb.create
end

def fillup_in_memory_db
  ## add some counties

  Country.create!( key: 'at', title: 'Austria', code: 'AUT', pop: 8000000, area: 80000 )
end

setup_in_memory_db()
fillup_in_memory_db()

AT =  Country.find_by_key!( 'at' )
