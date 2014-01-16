# encoding: UTF-8

module BeerDb::Model

  class BeerSerializer

    def initialize( beer )
      @beer = beer
    end
    
    attr_reader :beer
    
    def as_json
      brewery = {}
      if beer.brewery.present?
        brewery = { key: beer.brewery.key,
                    title: beer.brewery.title }
      end

      tags = []
      if beer.tags.present?
        beer.tags.each { |tag| tags << tag.key }
      end

      country = {
        key:   beer.country.key,
        title: beer.country.title
      }

      data = { key:      beer.key,
               title:    beer.title,
               synonyms: beer.synonyms,
               abv:      beer.abv,
               srm:      beer.srm,
               og:       beer.og,
               tags:     tags,
               brewery: brewery,
               country: country }
      
      data.to_json
    end

  end # class BeerSerializer

end # module BeerDb::Model
