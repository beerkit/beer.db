# encoding: UTF-8

module BeerDb
  module Model

class Brewery < ActiveRecord::Base

  extend TextUtils::TagHelper  # will add self.find_tags, self.find_tags_in_attribs!, etc.

  # NB: use extend - is_<type>? become class methods e.g. self.is_<type>? for use in
  #   self.create_or_update_from_values
  extend TextUtils::ValueHelper  # e.g. self.is_year?, self.is_state?, is_address?, is_taglist? etc.
  extend TextUtils::AddressHelper  # e.g self.normalize_addr, self.find_city_in_addr, etc.

  self.table_name = 'breweries'

  belongs_to :country, :class_name => 'WorldDb::Model::Country', :foreign_key => 'country_id'
  belongs_to :state,   :class_name => 'WorldDb::Model::State',   :foreign_key => 'state_id'
  belongs_to :city,    :class_name => 'WorldDb::Model::City',    :foreign_key => 'city_id'

  has_many   :beers,   :class_name => 'BeerDb::Model::Beer',     :foreign_key => 'brewery_id'
  has_many   :brands,  :class_name => 'BeerDb::Model::Brand',    :foreign_key => 'brand_id'

  has_many :taggings, class_name: 'TagDb::Model::Tagging', :as      => :taggable
  has_many :tags,     class_name: 'TagDb::Model::Tag',     :through => :taggings


  validates :key, :format => { :with => /\A[a-z][a-z0-9]+\z/, :message => 'expected two or more lowercase letters a-z or 0-9 digits' }


  ### support old names (read-only) for now  (remove later ??)

  def founded()        since;  end
  def founded=(value)  self.since = value; end

  def opened()        since;  end
  def openend=(value)  self.since = value; end

  def m?()  prod_m == true;  end
  def l?()  prod_l == true;  end

  ## TODO: activerecord supplies brewpub? already? same as attrib; check w/ test case (and remove here)
  def brewpub?()  brewpub == true;  end



  def as_json_v2( opts={} )
    # NB: do NOT overwrite "default" / builtin as_json, thus, lets use as_json_v2
    BrewerySerializer.new( self ).as_json
  end



  def self.create_or_update_from_values( values, more_attribs={} )
    attribs, more_values = find_key_n_title( values )
    attribs = attribs.merge( more_attribs )

    # check for optional values
    Brewery.create_or_update_from_attribs( attribs, more_values )
  end


  def self.create_or_update_from_attribs( new_attributes, values )

    ## fix: add/configure logger for ActiveRecord!!!
    logger = LogKernel::Logger.root

    value_tag_keys    = []
    value_brands      = ''

    ## check for grades (e.g. ***/**/*) in titles (will add new_attributes[:grade] to hash)
    ## if grade missing; set default to 4; lets us update overwrite 1,2,3 values on update
    new_attributes[ :grade ] ||= 4

    ### check for "default" tags - that is, if present new_attributes[:tags] remove from hash
    value_tag_keys += find_tags_in_attribs!( new_attributes )

    ## check for optional values
    values.each_with_index do |value,index|
      if match_country(value) do |country|
           new_attributes[ :country_id ] = country.id
         end
      elsif match_state_for_country(value,new_attributes[:country_id]) do |state|
              new_attributes[ :state_id ] = state.id
            end
      elsif match_city(value) do |city|
              if city.present?
                new_attributes[ :city_id ] = city.id
              else
                ## todo/fix: add strict mode flag - fail w/ exit 1 in strict mode
                logger.warn "city with key #{value[5..-1]} missing - for brewery #{new_attributes[:key]}"
              end

              ## for easy queries: cache state_id (from city)
              #  - check if city w/ state if yes, use it for brewery too
              if city.present? && city.state.present?
                new_attributes[ :state_id ] = city.state.id
              end
            end
      elsif match_year( value ) do |num|  # founded/established year e.g. 1776
              new_attributes[ :since ] = num
            end
      elsif match_hl( value ) do |num|  # e.g. 20_000 hl or 50hl etc.
              new_attributes[ :prod ] = num
            end
      elsif match_website( value ) do |website|  # check for url/internet address e.g. www.ottakringer.at
              # fix: support more url format (e.g. w/o www. - look for .com .country code etc.)
              new_attributes[ :web ] = website
            end
      elsif is_address?( value ) # if value includes // assume address e.g. 3970 Weitra // Sparkasseplatz 160
        new_attributes[ :address ] = normalize_addr( value )
      elsif value =~ /^brands:/   # brands:
        value_brands = value[7..-1]  ## cut off brands: prefix
        value_brands = value_brands.strip  # remove leading and trailing spaces
        # NB: brands get processed after record gets created (see below)
      elsif (values.size==(index+1)) && is_taglist?( value ) # tags must be last entry
        logger.debug "   found tags: >>#{value}<<"
        value_tag_keys += find_tags( value )
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
    # auto-add city if not present and country n state present

    if new_attributes[:city_id].blank? &&
       new_attributes[:country_id].present? &&
       new_attributes[:state_id].present?

      country_key = rec.country.key

      ###
      ## see  textutils/helper/address_helper for details about countries supported e.g.
      ##   github.com/rubylibs/textutils/blob/master/lib/textutils/helper/address_helper.rb

      if country_key == 'be' || country_key == 'at' ||
         country_key == 'de' ||
         country_key == 'cz' || country_key == 'sk' ||
         country_key == 'us'

        ## todo: how to handle nil/empty address lines?

        city_title = find_city_in_addr( new_attributes[:address], country_key )

        if city_title.present?

          ## for czech  - some cleanup
          ##   remove any (remaining) digits in city title
          city_title = city_title.gsub( /[0-9]/, '' ).strip

          city_values = [city_title]
          city_attributes = {
            country_id: rec.country_id,
            state_id:   rec.state_id
          }
          # todo: add convenience helper create_or_update_from_title
          city = City.create_or_update_from_values( city_values, city_attributes )

          ### fix/todo: set new autoadd flag too?
          ##  e.g. check if updated? e.g. timestamp created <> updated otherwise assume created?

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

      ## todo/fix: use strip_inline_comments (e.g #() or (()) - why?? why not??)
      #   - allows titles as usual (use new syntax for inline comments e.g. #() or (()) for example)

      # remove optional longer title part in () e.g. Las Palmas (de Gran Canaria), Palma (de Mallorca)
      value_brands = TextUtils.strip_subtitles( value_brands )

      brand_titles = value_brands.split( ',' )

      # pass 1) remove leading n trailing spaces
      brand_titles = brand_titles.map { |value| value.strip }

      brand_attribs = {
        brewery_id: rec.id,
        country_id: rec.country_id,
        state_id:   rec.state_id,
        city_id:    rec.city_id
      }

      brand_titles.each do |brand_title|
        Brand.create_or_update_from_title( brand_title, brand_attribs )
      end
    end

    ##################
    ## add taggings

##
##  fix: delete all tags first or only add diff?
##  fix e.g.
##
# [debug]    adding 1 taggings: >>trappist<<...
# rake aborted!
# ActiveRecord::RecordNotUnique: SQLite3::ConstraintException: columns taggable_id, taggable_type, tag_id are not unique: INSERT INTO "taggings" ("created_at", "tag_id", "taggable_id", "taggable_type", "updated_at") VALUES (?, ?, ?, ?, ?)
#    if value_tag_keys.size > 0

=begin
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
=end

    rec # NB: return created or updated obj

  end # method create_or_update_from_values


end # class Brewery

  end # module Model
end # module BeerDb
