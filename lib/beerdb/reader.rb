# encoding: UTF-8

module BeerDb

class Reader

  include LogUtils::Logging

  include BeerDb::Models

  attr_reader :include_path


  def initialize( include_path, opts = {} )
    @include_path = include_path
  end


  def load_setup( setup )
    ary = load_fixture_setup( setup )

    ary.each do |name|
      load( name )
    end
  end # method load_setup


  ## fix/todo: rename ??
  def load_fixture_setup( name )
    
   ## todo/fix: cleanup quick and dirty code
    
    path = "#{include_path}/#{name}.yml"

    logger.info "parsing data '#{name}' (#{path})..."

    text = File.read_utf8( path )
    
    hash = YAML.load( text )
    
    ### build up array for fixtures from hash
    
    ary = []
    
    hash.each do |key_wild, value_wild|
      key   = key_wild.to_s.strip
      
      logger.debug "yaml key:#{key_wild.class.name} >>#{key}<<, value:#{value_wild.class.name} >>#{value_wild}<<"
    
      if value_wild.kind_of?( String ) # assume single fixture name
        ary << value_wild
      elsif value_wild.kind_of?( Array ) # assume array of fixture names as strings
        ary = ary + value_wild
      else
        logger.error "unknow fixture type in setup (yaml key:#{key_wild.class.name} >>#{key}<<, value:#{value_wild.class.name} >>#{value_wild}<<); skipping"
      end
    end
    
    logger.debug "fixture setup:"
    logger.debug ary.to_json
    
    ary
  end # load_fixture_setup


  def load( name )

    if name =~ /\/([a-z]{2})\/beers/
      ## auto-add required country code (from folder structure)
      load_beers( $1, name )
    elsif name =~ /\.hl$/   # e.g. breweries.hl   # NB: must end w/ .hl
       load_brewery_prod( name )
    elsif name =~ /\/([a-z]{2})\.wikipedia/   # e.g. de.wikipedia
       # auto-add required lang e.g. de or en etc.
       load_brewery_wiki( $1, name )
    elsif name =~ /\/([a-z]{2})\/breweries_([a-z]{1,2})(?:_|$)/  # NB: region key must end name or be followed by underscore (_)
      ## auto-add required country code (from folder structure) plus region
      load_breweries_for_country_n_region( $1, $2, name )
    elsif name =~ /\/([a-z]{2})\/breweries/
      ## auto-add required country code (from folder structure)
      load_breweries_for_country( $1, name )
    else
      logger.error "unknown beer.db fixture type >#{name}<"
      # todo/fix: exit w/ error
    end
  end

  def load_brewery_wiki( lang_key, name )
    path = "#{include_path}/#{name}.yml"

    logger.info "parsing data '#{name}' (#{path})..."

    reader = HashReader.new( path )

    reader.each do |key, value|
      brewery = Brewery.find_by_key!( key )
      
      wiki = "#{lang_key}.wikipedia.org/wiki/#{value.strip}"
      logger.debug "  adding #{key} => >#{wiki}<"
      brewery.wiki = wiki
      brewery.save!
    end

    Prop.create_from_fixture!( name, path )
  end


  def load_brewery_prod( name )
    path = "#{include_path}/#{name}.yml"

    logger.info "parsing data '#{name}' (#{path})..."

    reader = HashReader.new( path )

    reader.each do |key, value|
      brewery = Brewery.find_by_key!( key )
      
      if value =~ /(?:([0-9][0-9_]*[0-9]|[0-9])\s*hl)/  # e.g. 20_0000 hl or 50hl etc.
        prod =  $1.gsub(/_/, '').to_i
        logger.debug "  adding #{key} => >#{prod}<"
        brewery.prod = prod
        brewery.save!
      else
        logger.warn "  unknown type for brewery prod value >#{value}<; regex pattern match failed"
      end
    end

    Prop.create_from_fixture!( name, path )
  end

  def load_beers( country_key, name, more_values={} )
    country = Country.find_by_key!( country_key )
    logger.debug "Country #{country.key} >#{country.title} (#{country.code})<"

    more_values[ :country_id ] = country.id

    path = "#{include_path}/#{name}.txt"

    logger.info "parsing data '#{name}' (#{path})..."

    reader = ValuesReader.new( path, more_values )

    reader.each_line do |new_attributes, values|
      Beer.create_or_update_from_values( new_attributes, values )
    end # each_line

    Prop.create_from_fixture!( name, path )
  end


  def load_breweries_for_country_n_region( country_key, region_key, name, more_values={} )
    country = Country.find_by_key!( country_key )
    logger.debug "Country #{country.key} >#{country.title} (#{country.code})<"

    # NB: region lookup requires country id (region key only unique for country)
    region  = Region.find_by_key_and_country_id!( region_key, country.id )
    logger.debug "Region #{region.key} >#{region.title}<"

    more_values[ :country_id ] = country.id
    more_values[ :region_id  ] = region.id

    load_breweries_worker( name, more_values )
  end


  def load_breweries_for_country( country_key, name, more_values={} )
    country = Country.find_by_key!( country_key )
    logger.debug "Country #{country.key} >#{country.title} (#{country.code})<"

    more_values[ :country_id ] = country.id

    load_breweries_worker( name, more_values )
  end


  def load_breweries_worker( name, more_values={} )
    path = "#{include_path}/#{name}.txt"

    logger.info "parsing data '#{name}' (#{path})..."

    reader = ValuesReader.new( path, more_values )
    
    reader.each_line do |new_attributes, values|
      Brewery.create_or_update_from_values( new_attributes, values )
    end # each_line

    Prop.create_from_fixture!( name, path )
  end

end # class Reader
end # module BeerDb
