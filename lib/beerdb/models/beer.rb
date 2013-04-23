module BeerDb::Models

class Beer < ActiveRecord::Base

  belongs_to :country, :class_name => 'WorldDb::Models::Country', :foreign_key => 'country_id'
  belongs_to :region,  :class_name => 'WorldDb::Models::Region',  :foreign_key => 'region_id'
  belongs_to :city,    :class_name => 'WorldDb::Models::City',    :foreign_key => 'city_id'

  belongs_to :brewery, :class_name => 'BeerDb::Models::Brewery',  :foreign_key => 'brewery_id'

  has_many :taggings, :as => :taggable, :class_name => 'WorldDb::Models::Tagging'
  has_many :tags,  :through => :taggings, :class_name => 'WorldDb::Models::Tag'


  ### support old names (read-only) for now  (remove later)

  def color
    srm
  end

  def plato
    og
  end

  def color=(value)
    self.srm = value
  end

  def plato=(value)
    self.og = value
  end


  def self.create_or_update_from_values( new_attributes, values )
    value_tag_keys    = []
      
    ### check for "default" tags - that is, if present new_attributes[:tags] remove from hash
      
    if new_attributes[:tags].present?
      more_tag_keys = new_attributes[:tags].split('|')
      new_attributes.delete(:tags)

      ## unify; replace _ w/ space; remove leading n trailing whitespace
      more_tag_keys = more_tag_keys.map do |key|
        key = key.gsub( '_', ' ' )
        key = key.strip
        key
      end

      value_tag_keys += more_tag_keys
    end


    ## check for optional values
    values.each_with_index do |value,index|
      if value =~ /^country:/   ## country:
        value_country_key = value[8..-1]  ## cut off country: prefix
        value_country = Country.find_by_key!( value_country_key )
        new_attributes[ :country_id ] = value_country.id
      elsif value =~ /^region:/   ## region:
        value_region_key = value[7..-1]  ## cut off region: prefix
        value_region = Region.find_by_key_and_country_id!( value_region_key, new_attributes[:country_id] )
        new_attributes[ :region_id ] = value_region.id
      elsif value =~ /^[A-Z]{1,2}$/  ## assume region code e.g. TX or N
        value_region = Region.find_by_key_and_country_id!( value.downcase, new_attributes[:country_id] )
        new_attributes[ :region_id ] = value_region.id
      elsif value =~ /^city:/   ## city:
        value_city_key = value[5..-1]  ## cut off city: prefix
        value_city = City.find_by_key( value_city_key )
        if value_city.present?
          new_attributes[ :city_id ] = value_city.id
        else
          ## todo/fix: add strict mode flag - fail w/ exit 1 in strict mode
          logger.warn "city with key #{value_city_key} missing"
        end
      elsif value =~ /^by:/   ## by:  -brewed by/brewery
        value_brewery_key = value[3..-1]  ## cut off by: prefix
        value_brewery = Brewery.find_by_key!( value_brewery_key )
        new_attributes[ :brewery_id ] = value_brewery.id

        # for easy queries cache city and region ids
          
        # 1) check if brewery has city - if yes, use it for beer too
        if value_brewery.city.present?
          new_attributes[ :city_id ] = value_brewery.city.id
        end

        # 2) check if brewery has city w/ region if yes, use it for beer to
        #   if not check for region for brewery
        if value_brewery.city.present? && value_brewery.city.region.present?
          new_attributes[ :region_id ] = value_brewery.city.region.id
        elsif value_brewery.region.present?
          new_attributes[ :region_id ] = value_brewery.region.id
        end

      elsif value =~ /^[0-9]{4}$/   # founded/established year e.g. 1776
        new_attributes[ :since ] = value.to_i
      elsif value =~ /^www\.|\.com$/   # check for url/internet address e.g. www.ottakringer.at
        # fix: support more url format (e.g. w/o www. - look for .com .country code etc.)
        new_attributes[ :web ] = value
      elsif value =~ /^<?\s*(\d+(?:\.\d+)?)\s*%$/  ## abv (alcohol by volumee)
        ## nb: allow leading < e.g. <0.5%
        value_abv_str = $1.dup   # convert to decimal? how? use float?
        new_attributes[ :abv ] = value_abv_str
      elsif value =~ /^(\d+(?:\.\d+)?)°$/  ## plato (stammwuerze/gravity?) e.g. 11.2°
        ## nb: no whitespace allowed between ° and number e.g. 11.2°
        value_og_str = $1.dup   # convert to decimal? how? use float?
        new_attributes[ :og ] = value_og_str
      elsif value =~ /^(\d+(?:\.\d+)?)\s*kcal(?:\/100ml)?$/  ## kcal
         ## nb: allow 44.4 kcal/100ml or 44.4 kcal or 44.4kcal
        value_kcal_str = $1.dup   # convert to decimal? how? use float?
        new_attributes[ :kcal ] = value_kcal_str
      elsif (values.size==(index+1)) && value =~ /^[a-z0-9\|_ ]+$/   # tags must be last entry

        logger.debug "   found tags: >>#{value}<<"

        tag_keys = value.split('|')
  
        ## unify; replace _ w/ space; remove leading n trailing whitespace
        tag_keys = tag_keys.map do |key|
          key = key.gsub( '_', ' ' )
          key = key.strip
          key
        end
          
        value_tag_keys += tag_keys
      else
        # issue warning: unknown type for value
        logger.warn "unknown type for value >#{value}<"
      end
    end # each value

    #  rec = Beer.find_by_key_and_country_id( new_attributes[ :key ], new_attributes[ :country_id] )
    rec = Beer.find_by_key( new_attributes[ :key ] )

    if rec.present?
      logger.debug "update Beer #{rec.id}-#{rec.key}:"
    else
      logger.debug "create Beer:"
      rec = Beer.new
    end
      
    logger.debug new_attributes.to_json

    rec.update_attributes!( new_attributes )

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

  end # method create_or_update_from_values

end # class Beer

end # module BeerDb::Models
