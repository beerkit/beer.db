# encoding: utf-8


module ApplicationHelper

  def app_title
   "Beer-A-Day"
  end
  
  def app_subtitle  # tagline
   "Cheers, Prost, Kampai, Na zdravi, Salute, 乾杯, Skål, Egészségedre!"
  end


  def beer_facts( beer )
    ##
    ## e.g. (9.0%, 20.0°)

    buf = ''
    facts = []
    facts << "#{beer.abv}%" if beer.abv.present?
    facts << "#{beer.og}°" if beer.og.present?
    buf << "(#{facts.join(', ')})" if facts.size > 0
    buf
  end

  def beer_headline( beer )
    ##
    ## e.g.  Gouden Carolus Tripel / Anker @ Mechelen › Antwerpen [Antwerp]

    buf = ''
    buf << beer.title
    if beer.brewery
      buf << " / #{beer.brewery.title}"
      if beer.brewery.founded
        ## buf << " (#{beer.brewery.founded})"
      end
      buf << " @ #{beer.brewery.city.name}" 
      buf << " › #{beer.brewery.region.name}"
      ## buf << " › #{beer.brewery.country.name}"
    else
      buf << ' / ???'
    end
    buf
  end

end
