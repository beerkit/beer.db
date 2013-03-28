### forward references
##   require first to resolve circular references

module BeerDb::Models

  ## todo: why? why not use include WorldDb::Models here???

  Continent = WorldDb::Models::Continent
  Country   = WorldDb::Models::Country
  Region    = WorldDb::Models::Region
  City      = WorldDb::Models::City
  Prop      = WorldDb::Models::Prop

  ## nb: for now only team and league use worlddb tables
  #   e.g. with belongs_to assoc (country,region)

  class Beer < ActiveRecord::Base ; end
  class Brewery < ActiveRecord::Base ; end

end


module WorldDb::Models

  # add alias? why? why not? # is there a better way?
  #  - just include SportDB::Models  - why? why not?
  #  - just include once in loader??
  Beer    = BeerDb::Models::Beer
  Brewery = BeerDb::Models::League

end
