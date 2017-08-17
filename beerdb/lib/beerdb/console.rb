# encoding: utf-8

## for use to run with interactive ruby (irb)
##  e.g.  irb -r sportdb/console

require 'beerdb/models'


## shortcuts for models

Beer    = BeerDb::Models::Beer
Brewery = BeerDb::Models::Brewery

Tag       = WorldDb::Models::Tag
Tagging   = WorldDb::Models::Tagging
Continent = WorldDb::Models::Continent
Country   = WorldDb::Models::Country
State     = WorldDb::Models::State
City      = WorldDb::Models::City
Prop      = WorldDb::Models::Prop

## connect to db

DB_CONFIG = {
  adapter:  'sqlite3',
  database: './beer.db'
}

pp DB_CONFIG
ActiveRecord::Base.establish_connection( DB_CONFIG )

## test drive

puts "Welcome to beer.db, version #{BeerDb::VERSION} (world.db, version #{WorldDb::VERSION})!"

BeerDb.tables

puts "Ready."

## add some predefined shortcuts

##### some countries

AT = Country.find_by_key( 'at' )
DE = Country.find_by_key( 'de' )
EN = Country.find_by_key( 'en' )

US = Country.find_by_key( 'us' )
MX = Country.find_by_key( 'mx' )

### some cities

WIEN = City.find_by_key( 'wien' )

### some states

NO = State.find_by_key_and_country_id( 'no', AT.id )  # at - niederoesterreich
OO = State.find_by_key_and_country_id( 'oo', AT.id )  # at - oberoesterreich

#### some beers

## to be done


### some breweries

OTTAKRINGER = Brewery.find_by_key( 'ottakringer' )
SCHWECHAT   = Brewery.find_by_key( 'schwechat' )


## turn on activerecord logging to console

ActiveRecord::Base.logger = Logger.new( STDOUT )
