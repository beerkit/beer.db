# encoding: UTF-8

module BeerDb::Model

  class BrewerySerializer

    def initialize( brewery )
      @brewery = brewery
    end
    
    attr_reader :brewery
    
    def as_json

      beers = []
      brewery.beers.each do |b|
        beers << { key: b.key, title: b.title }
      end

      tags = []
      if brewery.tags.present?
        brewery.tags.each { |tag| tags << tag.key }
      end

      country = {
        key:   brewery.country.key,
        title: brewery.country.title
      }

      data = { key:      brewery.key,
               title:    brewery.title,
               synonyms: brewery.synonyms,
               since:    brewery.since,
               address:  brewery.address,
               web:      brewery.web,
               prod:     brewery.prod,  # (estimated) annual production in hl e.g. 2_000 hl
               tags:     tags,
               beers:    beers,
               country:  country }

      data.to_json
    end

  end # class BrewerySerializer

end # module BeerDb::Model
