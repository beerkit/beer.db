# encoding: UTF-8

module BeerDb
  module Model

class Drink < ActiveRecord::Base

  belongs_to :beer, class_name: 'BeerDb::Model::Beer'
  belongs_to :user, class_name: 'BeerDb::Model::User'

  before_save :on_before_save

  def on_before_save
    # todo/check: can we use blank? for datetime too or just array,strings,etc.
    #  check - can we use/access created_at? already set for new records?

    self.drunk_at = Time.now   if drunk_at.blank?
  end


end # class Drink

  end # module Model
end # module BeerDb

