# encoding: UTF-8

module BeerDb::Models

class Note < ActiveRecord::Base

  belongs_to :beer, class_name: 'BeerDb::Models::Beer'
  belongs_to :user, class_name: 'BeerDb::Models::User'

end # class Note

end # module BeerDb::Models