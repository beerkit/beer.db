# encoding: UTF-8

module BeerDb


module Matcher

  def match_beers_for_country( name, &blk )
    match_xxx_for_country( name, 'beers', &blk )
  end

  def match_beers_for_country_n_state( name, &blk )
    match_xxx_for_country_n_state( name, 'beers', &blk )
  end

  def match_breweries_for_country( name, &blk )
    match_xxx_for_country( name, 'breweries', &blk )
  end

  def match_breweries_for_country_n_state( name, &blk )
    match_xxx_for_country_n_state( name, 'breweries', &blk )
  end

  def match_brewpubs_for_country( name, &blk )
    match_xxx_for_country( name, 'brewpubs', &blk )
  end

  def match_brewpubs_for_country_n_state( name, &blk )
    match_xxx_for_country_n_state( name, 'brewpubs', &blk )
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

    if match_beers_for_country_n_state( name ) do |country_key, state_key|
            load_beers_for_country_n_state( country_key, state_key, name )
          end
    elsif match_beers_for_country( name ) do |country_key|
            load_beers_for_country( country_key, name )
          end
    elsif match_breweries_for_country_n_state( name ) do |country_key, state_key|
            load_breweries_for_country_n_state( country_key, state_key, name )
          end
    elsif match_breweries_for_country( name ) do |country_key|
            load_breweries_for_country( country_key, name )
          end
    elsif match_brewpubs_for_country_n_state( name ) do |country_key, state_key|
            load_breweries_for_country_n_state( country_key, state_key, name, brewpub: true )
          end
    elsif match_brewpubs_for_country( name ) do |country_key|
            load_breweries_for_country( country_key, name, brewpub: true )
          end
    else
      logger.error "unknown beer.db fixture type >#{name}<"
      # todo/fix: exit w/ error
    end
  end


  def load_beers_for_country_n_state( country_key, state_key, name, more_attribs={} )
    country = Country.find_by!( key: country_key )
    logger.debug "Country #{country.key} >#{country.title} (#{country.code})<"
    more_attribs[ :country_id ] = country.id

    # Note: state lookup requires country id (state key only unique for country)
    ##  check: was find_by_key_and_country_id
    state  = State.find_by( key: state_key, country_id: country.id )
    if state.nil?
      # note: allow unknown state keys; issue warning n skip state
      logger.warn "State w/ key >#{state_key}< not found; skip adding state"
    else
      logger.debug "State #{state.key} >#{state.title}<"
      more_attribs[ :state_id  ] = state.id
    end

    more_attribs[ :txt ] = name  # store source ref

    load_beers_worker( name, more_attribs )
  end

  def load_beers_for_country( country_key, name, more_attribs={} )
    country = Country.find_by!( key: country_key )
    logger.debug "Country #{country.key} >#{country.title} (#{country.code})<"

    more_attribs[ :country_id ] = country.id

    more_attribs[ :txt ] = name  # store source ref

    load_beers_worker( name, more_attribs )
  end


  def load_breweries_for_country_n_state( country_key, state_key, name, more_attribs={} )
    country = Country.find_by!( key: country_key )
    logger.debug "Country #{country.key} >#{country.title} (#{country.code})<"

    more_attribs[ :country_id ] = country.id

    # note: state lookup requires country id (state key only unique for country)
    ##   was: State.find_by_key_and_country_id( state_key, country.id )
    state = State.find_by( key: state_key, country_id: country.id )
    if state.nil?
      # note: allow unknown state keys; issue warning n skip state
      logger.warn "State w/ key >#{state_key}< not found; skip adding state"
    else
      logger.debug "State #{state.key} >#{state.title}<"
      more_attribs[ :state_id  ] = state.id
    end

    more_attribs[ :txt ] = name  # store source ref

    load_breweries_worker( name, more_attribs )
  end

  def load_breweries_for_country( country_key, name, more_attribs={} )
    country = Country.find_by!( key: country_key )
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
