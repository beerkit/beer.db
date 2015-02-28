# encoding: UTF-8

module BeerDb


module Matcher

  def match_beers_for_country( name, &blk )
    match_xxx_for_country( name, 'beers', &blk )
  end

  def match_beers_for_country_n_region( name, &blk )
    match_xxx_for_country_n_region( name, 'beers', &blk )
  end

  def match_breweries_for_country( name, &blk )
    match_xxx_for_country( name, 'breweries', &blk )
  end

  def match_breweries_for_country_n_region( name, &blk )
    match_xxx_for_country_n_region( name, 'breweries', &blk )
  end

  def match_brewpubs_for_country( name, &blk )
    match_xxx_for_country( name, 'brewpubs', &blk )
  end

  def match_brewpubs_for_country_n_region( name, &blk )
    match_xxx_for_country_n_region( name, 'brewpubs', &blk )
  end


end # module Matcher


class ReaderBase

  include LogUtils::Logging

  include BeerDb::Models

  include WorldDb::Matcher   ## fix: move to BeerDb::Matcher module ??? - cleaner?? why? why not?
  include BeerDb::Matcher # lets us use match_teams_for_country etc.


  def load_setup( name )
    reader = create_fixture_reader( name )   ### "virtual" method - required by concrete class

    reader.each do |fixture_name|
      load( fixture_name )
    end
  end # method load_setup



  def load( name )

    if match_beers_for_country_n_region( name ) do |country_key, region_key|
            load_beers_for_country_n_region( country_key, region_key, name )
          end
    elsif match_beers_for_country( name ) do |country_key|
            load_beers_for_country( country_key, name )
          end
    elsif match_breweries_for_country_n_region( name ) do |country_key, region_key|
            load_breweries_for_country_n_region( country_key, region_key, name )
          end
    elsif match_breweries_for_country( name ) do |country_key|
            load_breweries_for_country( country_key, name )
          end
    elsif match_brewpubs_for_country_n_region( name ) do |country_key, region_key|
            load_breweries_for_country_n_region( country_key, region_key, name, brewpub: true )
          end
    elsif match_brewpubs_for_country( name ) do |country_key|
            load_breweries_for_country( country_key, name, brewpub: true )
          end
    else
      logger.error "unknown beer.db fixture type >#{name}<"
      # todo/fix: exit w/ error
    end
  end


  def load_beers_for_country_n_region( country_key, region_key, name, more_attribs={} )
    country = Country.find_by_key!( country_key )
    logger.debug "Country #{country.key} >#{country.title} (#{country.code})<"
    more_attribs[ :country_id ] = country.id

    # NB: region lookup requires country id (region key only unique for country)
    region  = Region.find_by_key_and_country_id( region_key, country.id )
    if region.nil?
      # note: allow unknown region keys; issue warning n skip region
      logger.warn "Region w/ key >#{region_key}< not found; skip adding region"
    else
      logger.debug "Region #{region.key} >#{region.title}<"
      more_attribs[ :region_id  ] = region.id
    end

    more_attribs[ :txt ] = name  # store source ref

    load_beers_worker( name, more_attribs )
  end

  def load_beers_for_country( country_key, name, more_attribs={} )
    country = Country.find_by_key!( country_key )
    logger.debug "Country #{country.key} >#{country.title} (#{country.code})<"

    more_attribs[ :country_id ] = country.id

    more_attribs[ :txt ] = name  # store source ref

    load_beers_worker( name, more_attribs )
  end


  def load_breweries_for_country_n_region( country_key, region_key, name, more_attribs={} )
    country = Country.find_by_key!( country_key )
    logger.debug "Country #{country.key} >#{country.title} (#{country.code})<"

    more_attribs[ :country_id ] = country.id

    # note: region lookup requires country id (region key only unique for country)
    region  = Region.find_by_key_and_country_id( region_key, country.id )
    if region.nil?
      # note: allow unknown region keys; issue warning n skip region
      logger.warn "Region w/ key >#{region_key}< not found; skip adding region"
    else
      logger.debug "Region #{region.key} >#{region.title}<"
      more_attribs[ :region_id  ] = region.id
    end

    more_attribs[ :txt ] = name  # store source ref

    load_breweries_worker( name, more_attribs )
  end

  def load_breweries_for_country( country_key, name, more_attribs={} )
    country = Country.find_by_key!( country_key )
    logger.debug "Country #{country.key} >#{country.title} (#{country.code})<"

    more_attribs[ :country_id ] = country.id

    more_attribs[ :txt ] = name  # store source ref

    load_breweries_worker( name, more_attribs )
  end



  def load_beers_worker( name, more_attribs )
    reader = create_beers_reader( name, more_attribs )
    reader.read
  end

  def load_breweries_worker( name, more_attribs )
    reader = create_breweries_reader( name, more_attribs )
    reader.read
  end

end # class ReaderBase
end # module BeerDb
