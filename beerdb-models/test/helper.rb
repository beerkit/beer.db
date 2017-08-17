
## $:.unshift(File.dirname(__FILE__))

## minitest setup

require 'minitest/autorun'


# our own code
require 'beerdb/models'


Country = WorldDb::Model::Country
State   = WorldDb::Model::State

## todo: get all models aliases (e.g. from console script)

Beer    = BeerDb::Model::Beer
Brand   = BeerDb::Model::Brand
Brewery = BeerDb::Model::Brewery


BeerDb.setup_in_memory_db()

## add some counties
AT = Country.create!( key: 'at', title: 'Austria', code: 'AUT', pop: 0, area: 0 )
W  = State.create!( key: 'w', title: 'Wien', country_id: AT.id )

DE = Country.create!( key: 'de', title: 'Germany', code: 'DEU', pop: 0, area: 0 )
BY = State.create!( key: 'by', title: 'Bayern', country_id: DE.id )
