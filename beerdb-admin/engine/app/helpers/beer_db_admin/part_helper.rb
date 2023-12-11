# encoding: utf-8

module BeerDbAdmin
module PartHelper

  def render_world_tree( o, opts={} )
    render partial: 'beer_db_admin/shared/world_tree',
           locals: { country: o.country,
                     region:  o.region,
                     city:    o.city,
                     show_flag: (opts[:flag].present? ? true : false) }
  end

  def render_countries( countries, opts={} )
    render partial: 'beer_db_admin/shared/countries',
           locals: { countries: countries }
  end

  def render_tags( tags )
    render partial: 'beer_db_admin/shared/tags', locals: { tags: tags }
  end

  def render_brewery_tags( brewery )
    # NB: will include "pseudo" tags such as production/capacity in hl and others
    render partial: 'beer_db_admin/shared/brewery_tags', locals: { brewery: brewery }
  end

  def render_beer( beer )
    render partial: 'beer_db_admin/shared/beer', locals: { beer: beer }
  end

  def render_beers( beers )
    render partial: 'beer_db_admin/shared/beers', locals: { beers: beers }
  end


  def render_breweries_table_rows( breweries )
    render partial: 'beer_db_admin/shared/breweries_table_rows',
      locals: { breweries: breweries }
  end
  
  def render_breweries_table_rows_for_region( region )
    render partial: 'beer_db_admin/shared/breweries_table_rows_for_region',
      locals: { region: region }
  end


  def render_breweries_for_city( city )
    render partial: 'beer_db_admin/shared/breweries_for_city', locals: { city: city }
  end

  def render_breweries_for_region( region )
    render partial: 'beer_db_admin/shared/breweries_for_region', locals: { region: region }
  end

  def render_breweries_for_country( country )
    render partial: 'beer_db_admin/shared/breweries_for_country', locals: { country: country }
  end


end # module PartHelper
end # module BeerDbAdmin
