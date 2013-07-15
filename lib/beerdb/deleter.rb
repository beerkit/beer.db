# encoding: utf-8

module BeerDb

  class Deleter
    
    include BeerDb::Models

    def run
      # for now delete all tables

      Bookmark.delete_all   # db model extension - move to its own addon?
      Drink.delete_all      # db model extension - move to its own addon?
      Note.delete_all       # db model extension - move to its own addon?
      User.delete_all       # db model extension - move to its own addon?

      Beer.delete_all
      Brand.delete_all
      Brewery.delete_all
    end
    
  end # class Deleter

end # module BeerDb
