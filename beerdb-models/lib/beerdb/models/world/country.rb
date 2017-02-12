# encoding: UTF-8

module WorldDb
  module Model

class Country
  has_many :beers,     :class_name => 'BeerDb::Model::Beer',    :foreign_key => 'country_id'
  has_many :brands,    :class_name => 'BeerDb::Model::Brand',   :foreign_key => 'country_id'
  has_many :breweries, :class_name => 'BeerDb::Model::Brewery', :foreign_key => 'country_id'
end # class Country

  end # module Model
end # module WorldDb

