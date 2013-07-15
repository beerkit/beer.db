### forward references
##   require first to resolve circular references

module BeerDb::Models

  ## todo: why? why not use include WorldDb::Models here???

  Continent = WorldDb::Models::Continent
  Country   = WorldDb::Models::Country
  Region    = WorldDb::Models::Region
  City      = WorldDb::Models::City

  Tag       = WorldDb::Models::Tag
  Tagging   = WorldDb::Models::Tagging

  Prop      = WorldDb::Models::Prop

  class Beer < ActiveRecord::Base ; end
  class Brand < ActiveRecord::Base ; end
  class Brewery < ActiveRecord::Base ; end

  class User < ActiveRecord::Base ; end
  class Bookmark < ActiveRecord::Base ; end
  class Drink < ActiveRecord::Base ; end
  class Note < ActiveRecord::Base ; end

end


module WorldDb::Models

  Beer    = BeerDb::Models::Beer
  Brand   = BeerDb::Models::Brand
  Brewery = BeerDb::Models::Brewery

end
