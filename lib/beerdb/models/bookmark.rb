# encoding: UTF-8

module BeerDb::Model

class Bookmark < ActiveRecord::Base

  belongs_to :bookmarkable, :polymorphic => true
  belongs_to :user


  ### fix - how to do it with has_many macro? use finder_sql?
  def drinks
    ## todo: check/assert bookmarkable_type == BeerDB::Models::Beer
    Drink.where( user_id: user_id, beer_id: bookmarkable_id )
  end

  def notes
    ## todo: check/assert bookmarkable_type == BeerDB::Models::Beer
    Note.where( user_id: user_id, beer_id: bookmarkable_id )
  end


  ## todo: check: how to handle polymorphic best for getting beer for bookmarkable?
  def beer
    ## todo: check/assert bookmarkable_type == BeerDB::Models::Beer
    Beer.find( bookmarkable_id )
  end

end # class Bookmark

end # module BeerDb::Model