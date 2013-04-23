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
    elsif name =~ /\/([a-z]{2})\/breweries/
      ## auto-add required country code (from folder structure)
      load_breweries( $1, name )
    else
      logger.error "unknown beer.db fixture type >#{name}<"
      # todo/fix: exit w/ error
    end
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


  def load_breweries( country_key, name, more_values={} )
    country = Country.find_by_key!( country_key )
    logger.debug "Country #{country.key} >#{country.title} (#{country.code})<"

    more_values[ :country_id ] = country.id

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
