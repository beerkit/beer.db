# encoding: UTF-8

## NB: just use namespace BeerDb::Model (not BeerDbService::Model or something else)

module BeerDb
  module Model

class Bookmark < ActiveRecord::Base

  belongs_to :bookmarkable, :polymorphic => true
  belongs_to :user


  ### fix - how to do it with has_many macro? use finder_sql?
  def drinks
    ## todo: check/assert bookmarkable_type == BeerDB::Model::Beer
    Drink.where( user_id: user_id, beer_id: bookmarkable_id )
  end

  def notes
    ## todo: check/assert bookmarkable_type == BeerDB::Model::Beer
    Note.where( user_id: user_id, beer_id: bookmarkable_id )
  end


  ## todo: check: how to handle polymorphic best for getting beer for bookmarkable?
  def beer
    ## todo: check/assert bookmarkable_type == BeerDB::Model::Beer
    Beer.find( bookmarkable_id )
  end

end # class Bookmark

  end # module Model
end # module BeerDb
