# encoding: UTF-8

module BeerDb


module Matcher

  def match_beers_for_country( name, &blk )
    match_xxx_for_country( name, 'beers', blk )
  end

  def match_beers_for_country_n_region( name, &blk )
    match_xxx_for_country_n_region( name, 'beers', blk )
  end

  def match_breweries_for_country( name, &blk )
    match_xxx_for_country( name, 'breweries', blk )
  end

  def match_breweries_for_country_n_region( name, &blk )
    match_xxx_for_country_n_region( name, 'breweries', blk )
  end

end # module Matcher


class Reader

  include LogUtils::Logging

  include BeerDb::Models

  include WorldDb::Matcher
  include BeerDb::Matcher # lets us use match_teams_for_country etc.

  attr_reader :include_path


  def initialize( include_path, opts = {} )
    @include_path = include_path
  end


  def load_setup( name )
    path = "#{include_path}/#{name}.yml"

    logger.info "parsing data '#{name}' (#{path})..."

    reader = FixtureReader.new( path )

    reader.each do |fixture_name|
      load( fixture_name )
    end
  end # method load_setup


  def load( name )

    if name =~ /\.hl$/   # e.g. breweries.hl   # NB: must end w/ .hl
       load_brewery_prod( name )
    elsif name =~ /\/([a-z]{2})\.wikipedia/   # e.g. de.wikipedia
       # auto-add required lang e.g. de or en etc.
       load_brewery_wikipedia( $1, name )
    elsif match_beers_for_country_n_region( name ) do |country_key, region_key|
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
    else
      logger.error "unknown beer.db fixture type >#{name}<"
      # todo/fix: exit w/ error
    end
  end


  def load_brewery_wikipedia( lang_key, name )
    reader = HashReaderV2.new( name, include_path )

    reader.each do |key, value|
      brewery = Brewery.find_by_key!( key )
      
      wikipedia = "#{lang_key}.wikipedia.org/wiki/#{value.strip}"
      logger.debug "  adding #{key} => >#{wikipedia}<"
      brewery.wikipedia = wikipedia
      brewery.save!
    end
  end


  def load_brewery_prod( name )
    reader = HashReaderV2.new( name, include_path )

    reader.each do |key, value|
      brewery = Brewery.find_by_key!( key )
      
      if value =~ /(?:([0-9][0-9_ ]+[0-9]|[0-9]{1,2})\s*hl)/  # e.g. 20_0000 hl or 50hl etc.
        prod =  $1.gsub(/[ _]/, '').to_i
        logger.debug "  adding #{key} => >#{prod}<"
        brewery.prod = prod
        brewery.save!
      else
        logger.warn "  unknown type for brewery prod value >#{value}<; regex pattern match failed"
      end
    end
  end

  def load_beers_for_country_n_region( country_key, region_key, name, more_attribs={} )
    country = Country.find_by_key!( country_key )
    logger.debug "Country #{country.key} >#{country.title} (#{country.code})<"

    # NB: region lookup requires country id (region key only unique for country)
    region  = Region.find_by_key_and_country_id!( region_key, country.id )
    logger.debug "Region #{region.key} >#{region.title}<"

    more_attribs[ :country_id ] = country.id
    more_attribs[ :region_id  ] = region.id
    
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

    reader.each_line do |new_attributes, values|
      Beer.create_or_update_from_attribs( new_attributes, values )
    end # each_line
  end


  def load_breweries_for_country_n_region( country_key, region_key, name, more_attribs={} )
    country = Country.find_by_key!( country_key )
    logger.debug "Country #{country.key} >#{country.title} (#{country.code})<"

    # NB: region lookup requires country id (region key only unique for country)
    region  = Region.find_by_key_and_country_id!( region_key, country.id )
    logger.debug "Region #{region.key} >#{region.title}<"

    more_attribs[ :country_id ] = country.id
    more_attribs[ :region_id  ] = region.id

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
      Brewery.create_or_update_from_attribs( new_attributes, values )
    end # each_line
  end

end # class Reader
end # module BeerDb
