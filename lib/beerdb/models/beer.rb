# encoding: UTF-8

module BeerDb::Models

class Beer < ActiveRecord::Base

  extend TextUtils::TagHelper  # will add self.find_tags, self.find_tags_in_attribs!, etc.

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
    value_tag_keys += find_tags_in_attribs!( attribs )

    ## check for optional values
    values.each_with_index do |value,index|
      if match_country(value) do |country|
           attribs[ :country_id ] = country.id
         end
      elsif match_region_for_country(value, attribs[:country_id]) do |region|
              attribs[ :region_id ] = region.id
            end
      elsif match_city(value) do |city|
              if city.present?
                attribs[ :city_id ] = city.id
              else
                ## todo/fix: add strict mode flag - fail w/ exit 1 in strict mode
                logger.warn "city with key #{value[5..-1]} missing for beer #{attribs[:key]}"
              end
            end
      elsif match_brewery(value) do |brewery|
              attribs[ :brewery_id ] = brewery.id

              # for easy queries cache city and region ids
          
              # 1) check if brewery has city - if yes, use it for beer too
              if brewery.city.present?
                attribs[ :city_id ] = brewery.city.id
              end

              # 2) check if brewery has city w/ region if yes, use it for beer to
              #   if not check for region for brewery
              if brewery.city.present? && brewery.city.region.present?
                attribs[ :region_id ] = brewery.city.region.id
              elsif brewery.region.present?
                attribs[ :region_id ] = brewery.region.id
              end
            end
      elsif match_year( value ) do |num|  # founded/established year e.g. 1776
              attribs[ :since ] = num
            end
      elsif match_website( value ) do |website|  # check for url/internet address e.g. www.ottakringer.at
              attribs[ :web ] = website
            end
      elsif match_abv( value ) do |num|   # abv (alcohol by volume)
              # nb: also allows leading < e.g. <0.5%
              attribs[ :abv ] = num
            end
      elsif match_og( value ) do |num|  # plato (stammwuerze/gravity?) e.g. 11.2°
              # nb: no whitespace allowed between ° and number e.g. 11.2°
              attribs[ :og ] = num
            end
      elsif match_kcal( value ) do |num| # kcal
              # nb: allow 44.4 kcal/100ml or 44.4 kcal or 44.4kcal
              attribs[ :kcal ] = num
            end
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
