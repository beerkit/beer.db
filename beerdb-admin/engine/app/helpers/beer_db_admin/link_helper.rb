# encoding: utf-8

module BeerDbAdmin
module LinkHelper


  def link_to_brewery( brewery, opts={} )
    link_to brewery.title, short_brewery_path( brewery )
  end

  def link_to_beer( beer, opts={} )
    link_to beer.title, short_beer_path( beer )
  end

  def link_to_city( city, opts={} )
    link_to city.title, short_city_path( city )
  end

  def link_to_region( region, opts={} )
    link_to region.title, short_region_path( region )
  end

  def link_to_country( country, opts={} )

    pp opts

    buf = ""

    ## add flag (image tag) if flag opt present e.g. flag:true
    if opts[:flag].present?
      puts "add flag (image tag) for country #{country.title}"
      buf << image_tag_for_country( country )
      buf << ' '
    end

    buf << link_to( country.title, short_country_path( country ))
    buf.html_safe   # note: make sure html will NOT get escaped
  end


end # module LinkHelper
end # moudle BeerDbAdmin
