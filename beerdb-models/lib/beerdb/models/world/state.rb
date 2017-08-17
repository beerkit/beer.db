# encoding: UTF-8

module WorldDb
  module Model

class State
  has_many :beers,     :class_name => 'BeerDb::Model::Beer',    :foreign_key => 'state_id'
  has_many :brands,    :class_name => 'BeerDb::Model::Brand',   :foreign_key => 'state_id'
  has_many :breweries, :class_name => 'BeerDb::Model::Brewery', :foreign_key => 'state_id'
end # class State

  end # module Model
end # module WorldDb
