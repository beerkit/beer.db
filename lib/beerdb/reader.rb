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

  ## todo: autoadd  brewpub flag!! use more_attribs??
  def match_brewpubs_for_country( name, &blk )
    match_xxx_for_country( name, 'brewpubs', &blk )
  end

  def match_brewpubs_for_country_n_region( name, &blk )
    match_xxx_for_country_n_region( name, 'brewpubs', &blk )
  end


end # module Matcher


class Reader

  include LogUtils::Logging

  include BeerDb::Models

  include WorldDb::Matcher   ## fix: move to BeerDb::Matcher module ??? - cleaner?? why? why not?
  include BeerDb::Matcher # lets us use match_teams_for_country etc.

  attr_reader :include_path


  def initialize( include_path, opts = {} )
    @include_path = include_path
  end


  def load_setup( name )
    path = "#{include_path}/#{name}.txt"

    logger.info "parsing data '#{name}' (#{path})..."

    reader = FixtureReader.new( path )

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
            ## todo: autoadd  brewpub flag!! use more_attribs??
            load_breweries_for_country_n_region( country_key, region_key, name )
          end
    elsif match_brewpubs_for_country( name ) do |country_key|
            ## todo: autoadd  brewpub flag!! use more_attribs??
            load_breweries_for_country( country_key, name )
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


  def load_beers_worker( name, more_attribs={} )
    reader = ValuesReaderV2.new( name, include_path, more_attribs )

    ### todo: cleanup - check if [] works for build_title...
    #     better cleaner way ???
    if more_attribs[:region_id].present?
      known_breweries_source = Brewery.where( region_id:  more_attribs[:region_id] )
    elsif more_attribs[:country_id].present?
      known_breweries_source = Brewery.where( country_id: more_attribs[:country_id] )
    else
      logger.warn "no region or country specified; use empty brewery ary for header mapper"
      known_breweries_source = []
    end

    known_breweries  = TextUtils.build_title_table_for( known_breweries_source )


    reader.each_line do |new_attributes, values|

      ## note: check for header attrib; if present remove
      ### todo: cleanup code later
      ## fix: add to new_attributes hash instead of values ary
      ##   - fix: match_brewery()   move region,city code out of values loop for reuse at the end
      if new_attributes[:header].present?
        brewery_line = new_attributes[:header].dup   # note: make sure we make a copy; will use in-place string ops
        new_attributes.delete(:header)   ## note: do NOT forget to remove from hash!

        logger.debug "  trying to find brewery in line >#{brewery_line}<"
        ## todo: check what map_titles_for! returns (nothing ???)
        TextUtils.map_titles_for!( 'brewery', brewery_line, known_breweries )
        brewery_key = TextUtils.find_key_for!( 'brewery', brewery_line )
        logger.debug "  brewery_key = >#{brewery_key}<"
        unless brewery_key.nil?
          ## bingo! add brewery_id upfront, that is, as first value in ary
          values = values.unshift "by:#{brewery_key}"
        end
      end

      Beer.create_or_update_from_attribs( new_attributes, values )
    end # each_line
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

  def load_breweries_worker( name, more_attribs={} )
    reader = ValuesReaderV2.new( name, include_path, more_attribs )

    reader.each_line do |new_attributes, values|
      
      #######
      # fix: move to (inside)
      #    Brewery.create_or_update_from_attribs ||||
      ## note: group header not used for now; do NOT forget to remove from hash!
      if new_attributes[:header].present?
        logger.warn "removing unused group header #{new_attributes[:header]}"
        new_attributes.delete(:header)   ## note: do NOT forget to remove from hash!
      end
      
      Brewery.create_or_update_from_attribs( new_attributes, values )
    end # each_line
  end

end # class Reader
end # module BeerDb
