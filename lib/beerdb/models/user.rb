# encoding: UTF-8

module BeerDb::Models

class User < ActiveRecord::Base

  has_many :notes # beers w/ ratings
  has_many :drinks

  has_many :bookmarks # bookmarked beers


  before_save :on_before_save

  def on_before_save
    if email.blank?
      self.key = 'xxx'
    else
      # NB: remove whitespace and (.-+_) and downcase
      self.key = email.gsub( /[\s\.\-+_]/, '' ).downcase
    end
  end

end # class User

end # module BeerDb::Models