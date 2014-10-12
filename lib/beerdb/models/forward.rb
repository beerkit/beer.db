# encoding: UTF-8


### forward references
##   require first to resolve circular references


module BeerDb
  module Model

  ## todo: why? why not use include WorldDb::Models here???

  Continent = WorldDb::Model::Continent
  Country   = WorldDb::Model::Country
  Region    = WorldDb::Model::Region
  City      = WorldDb::Model::City

  Tag       = TagDb::Model::Tag
  Tagging   = TagDb::Model::Tagging

  Prop      = ConfDb::Model::Prop

  class Beer < ActiveRecord::Base ; end
  class Brand < ActiveRecord::Base ; end
  class Brewery < ActiveRecord::Base ; end

  class User < ActiveRecord::Base ; end
  class Bookmark < ActiveRecord::Base ; end
  class Drink < ActiveRecord::Base ; end
  class Note < ActiveRecord::Base ; end

  end # module Model
end # module BeerDb


module WorldDb
  module Model

  Beer    = BeerDb::Model::Beer
  Brand   = BeerDb::Model::Brand
  Brewery = BeerDb::Model::Brewery

  end # module Model
end # module WorldDb

