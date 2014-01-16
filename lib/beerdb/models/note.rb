# encoding: UTF-8

module BeerDb::Model

class Note < ActiveRecord::Base

  belongs_to :beer, class_name: 'BeerDb::Model::Beer'
  belongs_to :user, class_name: 'BeerDb::Model::User'

end # class Note

end # module BeerDb::Model
