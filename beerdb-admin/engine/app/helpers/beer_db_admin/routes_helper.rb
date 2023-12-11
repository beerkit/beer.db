# encoding: utf-8

module BeerDbAdmin
module RoutesHelper

  ##############################
  ## routes for shortcuts
  
  def short_country_path( country, opts={} )
    short_country_worker_path( country.key, opts )
  end

  def short_region_path( region, opts={} )
    short_region_worker_path( "#{region.country.key}-#{region.key}", opts )
  end

  def short_city_path( city, opts={} )
    short_city_worker_path( city.key, opts )
  end


  def short_brewery_path( brewery, opts={} )
    short_brewery_worker_path( brewery.key, opts )
  end

  def short_beer_path( beer, opts={} )
    short_beer_worker_path( beer.key, opts )
  end

=begin
  def short_tag_path( tag, opts={} )
    ## NB: tag needs slug NOT key (key may contain spaces)
    short_tag_worker_path( tag.slug, opts )
  end
=end

end # module RoutesHelper
end # moudle BeerDbAdmin
