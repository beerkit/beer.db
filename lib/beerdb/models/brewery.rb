# encoding: UTF-8

module BeerDb::Models

class Brewery < ActiveRecord::Base

  # NB: use extend - is_<type>? become class methods e.g. self.is_<type>? for use in
  #   self.create_or_update_from_values
  extend TextUtils::ValueHelper  # e.g. is_year?, is_region?, is_address?, is_taglist? etc.

  self.table_name = 'breweries'

  belongs_to :country, :class_name => 'WorldDb::Models::Country', :foreign_key => 'country_id'
  belongs_to :region,  :class_name => 'WorldDb::Models::Region',  :foreign_key => 'region_id'
  belongs_to :city,    :class_name => 'WorldDb::Models::City',    :foreign_key => 'city_id'

  has_many   :beers,   :class_name => 'BeerDb::Models::Beer',     :foreign_key => 'brewery_id'
  has_many   :brands,  :class_name => 'BeerDb::Models::Brand',    :foreign_key => 'brand_id'

  has_many :taggings, :as => :taggable, :class_name => 'WorldDb::Models::Tagging'
  has_many :tags,  :through => :taggings, :class_name => 'WorldDb::Models::Tag'

  validates :key, :format => { :with => /^[a-z][a-z0-9]+$/, :message => 'expected two or more lowercase letters a-z or 0-9 digits' }


  def self.rnd  # find random beer  - fix: use "generic" activerecord helper and include/extend class
    rnd_offset = rand( Brewery.count )   ## NB: call "global" std lib rand
    Brewery.offset( rnd_offset ).limit( 1 )
  end


  ### support old names (read-only) for now  (remove later)

  def founded
    since
  end

  def founded=(value)
    self.since = value
  end



  ## todo/fix:
  #    move to textutils - use AddressHelper ??
  #  todo: add _in_adr or _in_addr to name

  def self.find_city_for_country( country_key, address )

    return nil if address.blank?    # do NOT process nil or empty address lines; sorry

    lines = address.split( '//' )

    if country_key == 'at' || country_key == 'de'
      # first line strip numbers (assuming zip code) and whitespace
      line1 = lines[0]
      line1 = line1.gsub( /\b[0-9]+\b/, '' )   # use word boundries (why? why not?)
      line1 = line1.strip
      
      return nil if line1.blank?   # nothing left sorry; better return nil
      
      line1   # assume its the city
    else
      nil   # unsupported country/address schema for now; sorry
    end
  end


  def self.find_grade( text )  # NB: returns ary [grade,text] / two values
    grade = 4  # defaults to grade 4  e.g  *** => 1, ** => 2, * => 3, -/- => 4

    text = text.sub( /\s+(\*{1,3})\s*$/ ) do |_|  # NB: stars must end field/value
      if $1 == '***'
        grade = 1
      elsif $1 == '**'
        grade = 2
      elsif $1 == '*'
        grade = 3
      else
        # unknown grade; not possible, is'it?
      end
      ''  # remove * from title if found
    end

    [grade,text]
  end

  ## todo/fix: move to helper for reuse in textutils!!! (use for beer model too)

  def self.find_grade_in_titles!( new_attributes )

    # NB: will add a new attributes grade to hash e.g. new_attributes[:grade] = grade

    if new_attributes[:title].present?
      grade, title = find_grade( new_attributes[:title] )
      
      if grade == 1 || grade == 2 || grade == 3  # grade found/present; use stripped title
        new_attributes[:title] = title
        new_attributes[:grade] = grade
        return grade
      end
    end  
      
    if new_attributes[:synonyms].present?
      grade, synonyms = find_grade( new_attributes[:synonyms] )
      
      if grade == 1 || grade == 2 || grade == 3  # grade found/present; use stripped title
        new_attributes[:synonyms] = synonyms
        new_attributes[:grade] = grade
        return grade
      end
    end  
      
    grade = 4  # defaults to grade 4  e.g  *** => 1, ** => 2, * => 3, -/- => 4
    new_attributes[:grade] = grade
    grade
  end


  def self.create_or_update_from_values( new_attributes, values )

    ## fix: add/configure logger for ActiveRecord!!!
    logger = LogKernel::Logger.root

    value_tag_keys    = []
    value_brands      = ''

    ## check for grades (e.g. ***/**/*) in titles (will add new_attributes[:grade] to hash)
    find_grade_in_titles!( new_attributes )

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
      elsif is_region?( value )  ## assume region code e.g. TX or N
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

        ## for easy queries: cache region_id (from city)
        #  - check if city w/ region if yes, use it for brewery too
        if value_city.present? && value_city.region.present?
          new_attributes[ :region_id ] = value_city.region.id
        end
      elsif is_year?( value )  # founded/established year e.g. 1776
        new_attributes[ :since ] = value.to_i
      elsif value =~ /^(?:([0-9][0-9_ ]+[0-9]|[0-9]{1,2})\s*hl)$/  # e.g. 20_000 hl or 50hl etc.
        value_prod = $1.gsub( /[ _]/, '' ).to_i
        new_attributes[ :prod ] = value_prod
      elsif is_website?( value )   # check for url/internet address e.g. www.ottakringer.at
        # fix: support more url format (e.g. w/o www. - look for .com .country code etc.)
        new_attributes[ :web ] = value
      elsif is_address?( value ) # if value includes // assume address e.g. 3970 Weitra // Sparkasseplatz 160
        new_attributes[ :address ] = TextUtils.normalize_address( value )
      elsif value =~ /^brands:/   # brands:
        value_brands = value[7..-1]  ## cut off brands: prefix
        value_brands = value_brands.strip  # remove leading and trailing spaces
        # NB: brands get processed after record gets created (see below)
      elsif (values.size==(index+1)) && is_taglist?( value ) # tags must be last entry

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
        logger.warn "unknown type for value >#{value}< - key #{new_attributes[:key]}"
      end
    end # each value

    ## todo: check better style using self.find_by_key?? why? why not?
    rec = Brewery.find_by_key( new_attributes[ :key ] )

    if rec.present?
      logger.debug "update Brewery #{rec.id}-#{rec.key}:"
    else
      logger.debug "create Brewery:"
      rec = Brewery.new
    end
      
    logger.debug new_attributes.to_json

    rec.update_attributes!( new_attributes )


    ##############################
    # auto-add city if not present and country n region present
    
    if new_attributes[:city_id].blank? &&
       new_attributes[:country_id].present? &&
       new_attributes[:region_id].present?
       
      country_key = rec.country.key

      if country_key == 'at' || country_key == 'de'

        ## todo: how to handle nil/empty address lines?

        ## todo: use find_city_in_adr_for_country ?? too long ?? use adr or addr
        city_title = find_city_for_country( country_key, new_attributes[:address] )
        
        if city_title.present?
          
          # remove optional english translation in square brackets ([]) e.g. Wien [Vienna]
          city_title = TextUtils.strip_translations( city_title )
          # remove optional longer title part in {} e.g. Ottakringer {Bio} or {Alkoholfrei}
          city_title = TextUtils.strip_tags( city_title )
          
          city_key = TextUtils.title_to_key( city_title )

          city = City.find_by_key( city_key )

          city_attributes = {
            title:      city_title,
            country_id: rec.country_id,
            region_id:  rec.region_id
            ### fix/todo: add new autoadd flag too?
          }

          if city.present?
            logger.debug "update City #{city.id}-#{city.key}:"
            # todo: check - any point in updating city? for now no new attributes
            #   update only for title - title will change?
          else
            logger.debug "create City:"
            city = City.new
            city_attributes[ :key ] = city_key   # NB: new record; include/update key
          end

          logger.info city_attributes.to_json

          city.update_attributes!( city_attributes )

          ## now at last add city_id to brewery!
          rec.city_id = city.id
          rec.save!
        else
          logger.warn "auto-add city for #{new_attributes[:key]} (#{country_key}) >>#{new_attributes[:address]}<< failed; no city title found"
        end
      end
    end


    ###################
    # auto-add brands if presents

    if value_brands.present?
      logger.debug " auto-adding brands >#{value_brands}<"

      # remove optional english translation in square brackets ([]) e.g. Wien [Vienna]
      value_brands = TextUtils.strip_translations( value_brands )

      # remove optional longer title part in () e.g. Las Palmas (de Gran Canaria), Palma (de Mallorca)
      value_brands = TextUtils.strip_subtitles( value_brands )

      # remove optional longer title part in {} e.g. Ottakringer {Bio} or {Alkoholfrei}
      value_brands = TextUtils.strip_tags( value_brands )

      value_brand_titles = value_brands.split( ',' )

      # pass 1) remove leading n trailing spaces
      value_brand_titles = value_brand_titles.map { |value| value.strip }

      value_brand_titles.each do |brand_title|
        
        # autogenerate key from title
        brand_key = TextUtils.title_to_key( brand_title )

        brand = Brand.find_by_key( brand_key )

        brand_attributes = {
          title:      brand_title,
          brewery_id: rec.id,
          country_id: rec.country_id,
          region_id:  rec.region_id,
          city_id:    rec.city_id
        }

        if brand.present?
          logger.debug "update Brand #{brand.id}-#{brand.key}:"
        else
          logger.debug "create Brand:"
          brand = Brand.new
          brand_attributes[ :key ] = brand_key   # NB: new record; include/update key
        end
      
        logger.debug brand_attributes.to_json

        brand.update_attributes!( brand_attributes )
      end
    end

    ##################
    ## add taggings

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


end # class Brewery


end # module BeerDb::Models
