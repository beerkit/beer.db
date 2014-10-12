# encoding: UTF-8

module WorldDb
  module Model

class Region
    has_many :beers,     :class_name => 'BeerDb::Model::Beer',    :foreign_key => 'region_id'
    has_many :brands,    :class_name => 'BeerDb::Model::Brand',   :foreign_key => 'region_id'
    has_many :breweries, :class_name => 'BeerDb::Model::Brewery', :foreign_key => 'region_id'
end # class Region

  end # module Model
end # module WorldDb

