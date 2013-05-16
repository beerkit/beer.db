# encoding: UTF-8

module BeerDb::Models

class Beer < ActiveRecord::Base

  extend TextUtils::TagHelper  # will add self.find_tags, self.find_tags_in_hash!, etc.

  # NB: use extend - is_<type>? become class methods e.g. self.is_<type>? for use in
  #   self.create_or_update_from_values
  extend TextUtils::ValueHelper  # e.g. self.is_year?, self.is_region?, self.is_address?, is_taglist? etc.

  belongs_to :country, :class_name => 'WorldDb::Models::Country', :foreign_key => 'country_id'
  belongs_to :region,  :class_name => 'WorldDb::Models::Region',  :foreign_key => 'region_id'
  belongs_to :city,    :class_name => 'WorldDb::Models::City',    :foreign_key => 'city_id'

  belongs_to :brand,   :class_name => 'BeerDb::Models::Brewery',  :foreign_key => 'brand_id'
  belongs_to :brewery, :class_name => 'BeerDb::Models::Brewery',  :foreign_key => 'brewery_id'

  has_many :taggings, :as => :taggable, :class_name => 'WorldDb::Models::Tagging'
  has_many :tags,  :through => :taggings, :class_name => 'WorldDb::Models::Tag'

  validates :key, :format => { :with => /^[a-z][a-z0-9]+$/, :message => 'expected two or more lowercase letters a-z or 0-9 digits' }


  def self.rnd  # find random beer  - fix: use "generic" activerecord helper and include/extend class
    rnd_offset = rand( Beer.count )   ## NB: call "global" std lib rand
    Beer.offset( rnd_offset ).limit( 1 )
  end

  ### support old names (read-only) for now  (remove later)

  def color
    puts "*** depreceated fn api - use srm"
    srm
  end

  def plato
    puts "*** depreceated fn api - use og"
    og
  end

  def color=(value)
    puts "*** depreceated fn api - use srm="
    self.srm = value
  end

  def plato=(value)
    puts "*** depreceated fn api - use og="
    self.og = value
  end
  
  def as_json_v2( opts={} )
    # NB: do NOT overwrite "default" / builtin as_json, thus, lets use as_json_v2
    BeerSerializer.new( self ).as_json
  end


  def self.create_or_update_from_values( values, more_attribs={} )

    attribs, more_values = find_key_n_title( values )
    attribs = attribs.merge( more_attribs )
      
    # check for optional values
    Beer.create_or_update_from_attribs( attribs, more_values )
  end


  def self.create_or_update_from_attribs( attribs, values )

    # fix: add/configure logger for ActiveRecord!!!
    logger = LogKernel::Logger.root
    
    value_tag_keys    = []
     
    ## check for grades (e.g. ***/**/*) in titles (will add attribs[:grade] to hash)
    ## if grade missing; set default to 4; lets us update overwrite 1,2,3 values on update
    attribs[ :grade ] ||= 4
           
    ### check for "default" tags - that is, if present attribs[:tags] remove from hash
    value_tag_keys += find_tags_in_hash!( attribs )

    ## check for optional values
    values.each_with_index do |value,index|
      if value =~ /^country:/   ## country:
        value_country_key = value[8..-1]  ## cut off country: prefix
        value_country = Country.find_by_key!( value_country_key )
        attribs[ :country_id ] = value_country.id
      elsif value =~ /^region:/   ## region:
        value_region_key = value[7..-1]  ## cut off region: prefix
        value_region = Region.find_by_key_and_country_id!( value_region_key, attribs[:country_id] )
        attribs[ :region_id ] = value_region.id
      elsif is_region?( value )  ## assume region code e.g. TX or N
        value_region = Region.find_by_key_and_country_id!( value.downcase, attribs[:country_id] )
        attribs[ :region_id ] = value_region.id
      elsif value =~ /^city:/   ## city:
        value_city_key = value[5..-1]  ## cut off city: prefix
        value_city = City.find_by_key( value_city_key )
        if value_city.present?
          attribs[ :city_id ] = value_city.id
        else
          ## todo/fix: add strict mode flag - fail w/ exit 1 in strict mode
          logger.warn "city with key #{value_city_key} missing for beer #{attribs[:key]}"
        end
      elsif value =~ /^by:/   ## by:  -brewed by/brewery
        value_brewery_key = value[3..-1]  ## cut off by: prefix
        value_brewery = Brewery.find_by_key!( value_brewery_key )
        attribs[ :brewery_id ] = value_brewery.id

        # for easy queries cache city and region ids
          
        # 1) check if brewery has city - if yes, use it for beer too
        if value_brewery.city.present?
          attribs[ :city_id ] = value_brewery.city.id
        end

        # 2) check if brewery has city w/ region if yes, use it for beer to
        #   if not check for region for brewery
        if value_brewery.city.present? && value_brewery.city.region.present?
          attribs[ :region_id ] = value_brewery.city.region.id
        elsif value_brewery.region.present?
          attribs[ :region_id ] = value_brewery.region.id
        end

      elsif is_year?( value )  # founded/established year e.g. 1776
        attribs[ :since ] = value.to_i
      elsif is_website?( value )   # check for url/internet address e.g. www.ottakringer.at
        # fix: support more url format (e.g. w/o www. - look for .com .country code etc.)
        attribs[ :web ] = value
      elsif value =~ /^<?\s*(\d+(?:\.\d+)?)\s*%$/  ## abv (alcohol by volumee)
        ## nb: allow leading < e.g. <0.5%
        value_abv_str = $1.dup   # convert to decimal? how? use float?
        attribs[ :abv ] = value_abv_str
      elsif value =~ /^(\d+(?:\.\d+)?)°$/  ## plato (stammwuerze/gravity?) e.g. 11.2°
        ## nb: no whitespace allowed between ° and number e.g. 11.2°
        value_og_str = $1.dup   # convert to decimal? how? use float?
        attribs[ :og ] = value_og_str
      elsif value =~ /^(\d+(?:\.\d+)?)\s*kcal(?:\/100ml)?$/  ## kcal
         ## nb: allow 44.4 kcal/100ml or 44.4 kcal or 44.4kcal
        value_kcal_str = $1.dup   # convert to decimal? how? use float?
        attribs[ :kcal ] = value_kcal_str
      elsif (values.size==(index+1)) && is_taglist?( value )  # tags must be last entry
        logger.debug "   found tags: >>#{value}<<"
        value_tag_keys += find_tags( value )
      else
        # issue warning: unknown type for value
        logger.warn "unknown type for value >#{value}< - key #{attribs[:key]}"
      end
    end # each value

    #  rec = Beer.find_by_key_and_country_id( attribs[ :key ], attribs[ :country_id] )
    rec = Beer.find_by_key( attribs[ :key ] )

    if rec.present?
      logger.debug "update Beer #{rec.id}-#{rec.key}:"
    else
      logger.debug "create Beer:"
      rec = Beer.new
    end
      
    logger.debug attribs.to_json

    rec.update_attributes!( attribs )

    ##################
    # add taggings 

    if value_tag_keys.size > 0
        
        value_tag_keys.uniq!  # remove duplicates
        logger.debug "   adding #{value_tag_keys.size} taggings: >>#{value_tag_keys.join('|')}<<..."

        ### fix/todo: check tag_ids and only update diff (add/remove ids)

        value_tag_keys.each do |key|
          tag = Tag.find_by_key( key )
          if tag.nil?  # create tag if it doesn't exit
            logger.debug "   creating tag >#{key}<"
            tag = Tag.create!( key: key )
          end
          rec.tags << tag
        end
    end
    
    rec # NB: return created or updated obj

  end # method create_or_update_from_values

end # class Beer

end # module BeerDb::Models
