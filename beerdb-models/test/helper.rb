
## $:.unshift(File.dirname(__FILE__))

## minitest setup

require 'minitest/autorun'


# our own code
require 'beerdb/models'


Country = WorldDb::Model::Country
Region  = WorldDb::Model::Region

## todo: get all models aliases (e.g. from console script)

Beer    = BeerDb::Model::Beer
Brand   = BeerDb::Model::Brand
Brewery = BeerDb::Model::Brewery


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
  BeerDb.create_all
end


def fillup_in_memory_db
  ## add some counties

  at = Country.create!( key: 'at', title: 'Austria', code: 'AUT', pop: 0, area: 0 )
  Region.create!( key: 'w', title: 'Wien', country_id: at.id )
  
  de = Country.create!( key: 'de', title: 'Germany', code: 'DEU', pop: 0, area: 0 )
  Region.create!( key: 'by', title: 'Bayern', country_id: de.id )
  
end

setup_in_memory_db()
fillup_in_memory_db()

AT   =  Country.find_by_key!( 'at' )
W    =  Region.find_by_key!( 'w' )

DE   =  Country.find_by_key!( 'de' )
BY   =  Region.find_by_key!( 'by' )