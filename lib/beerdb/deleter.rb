# encoding: utf-8

module BeerDb

  class Deleter
    
    include BeerDb::Models

    def run
      # for now delete all tables

      Beer.delete_all
      Brand.delete_all
      Brewery.delete_all
    end
    
  end # class Deleter

end # module BeerDb
