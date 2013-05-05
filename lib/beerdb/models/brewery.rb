# encoding: UTF-8

module BeerDb::Models

class Brewery < ActiveRecord::Base

  self.table_name = 'breweries'

  belongs_to :country, :class_name => 'WorldDb::Models::Country', :foreign_key => 'country_id'
  belongs_to :region,  :class_name => 'WorldDb::Models::Region',  :foreign_key => 'region_id'
  belongs_to :city,    :class_name => 'WorldDb::Models::City',    :foreign_key => 'city_id'

  has_many   :beers,   :class_name => 'BeerDb::Models::Beer',     :foreign_key => 'brewery_id'
  has_many   :brands,  :class_name => 'BeerDb::Models::Brand',    :foreign_key => 'brand_id'

  has_many :taggings, :as => :taggable, :class_name => 'WorldDb::Models::Tagging'
  has_many :tags,  :through => :taggings, :class_name => 'WorldDb::Models::Tag'

  validates :key, :format => { :with => /^[a-z][a-z0-9]+$/, :message => 'expected two or more lowercase letters a-z or 0-9 digits' }

  ### support old names (read-only) for now  (remove later)

  def founded
    since
  end

  def founded=(value)
    self.since = value
  end


  def self.create_or_update_from_values( new_attributes, values )

    ## fix: add/configure logger for ActiveRecord!!!
    logger = LogKernel::Logger.root

    value_tag_keys    = []
    value_brands      = ''

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

        ## for easy queries: cache region_id (from city)
        #  - check if city w/ region if yes, use it for brewery too
        if value_city.present? && value_city.region.present?
          new_attributes[ :region_id ] = value_city.region.id
        end
      elsif value =~ /^[0-9]{4}$/   # founded/established year e.g. 1776
        new_attributes[ :since ] = value.to_i
      elsif value =~ /^(?:([0-9][0-9_ ]+[0-9]|[0-9]{1,2})\s*hl)$/  # e.g. 20_000 hl or 50hl etc.
        value_prod = $1.gsub( /[ _]/, '' ).to_i
        new_attributes[ :prod ] = value_prod
      elsif value =~ /^www\.|\.com$/   # check for url/internet address e.g. www.ottakringer.at
        # fix: support more url format (e.g. w/o www. - look for .com .country code etc.)
        new_attributes[ :web ] = value
      elsif value =~ /\/{2}/  # if value includes // assume address e.g. 3970 Weitra // Sparkasseplatz 160
        new_attributes[ :address ] = normalize_address( value )
      elsif value =~ /^brands:/   # brands:
        value_brands = value[7..-1]  ## cut off brands: prefix
        value_brands = value_brands.strip  # remove leading and trailing spaces
        # NB: brands get processed after record gets created (see below)
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

    ###################
    # auto-add brands if presents

    if value_brands.present?
      logger.debug " auto-adding brands >#{value_brands}<"

      # remove optional english translation in square brackets ([]) e.g. Wien [Vienna]
      value_brands = value_brands.gsub( /\[.+\]/, '' )

      # remove optional longer title part in () e.g. Las Palmas (de Gran Canaria), Palma (de Mallorca)
      value_brands = value_brands.gsub( /\(.+\)/, '' )
      
      # remove optional longer title part in {} e.g. Ottakringer {Bio} or {Alkoholfrei}
      value_brands = value_brands.gsub( /\{.+\}/, '' )
      
      value_brand_titles = value_brands.split( ',' )
      
      # pass 1) remove leading n trailing spaces
      value_brand_titles = value_brand_titles.map { |value| value.strip }
      
      value_brand_titles.each do |brand_title|
        
        # autogenerate key from title
        brand_key = title_to_key( brand_title )

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

  end # method create_or_update_from_values

  ### todo/fix:
  # reuse method - put into helper in textutils or somewhere else ??

  def self.normalize_address( old_address_line )
    # for now only checks german 5-digit zip code
    #
    #  e.g.  Alte Plauener Straße 24 // 95028 Hof  becomes
    #        95028 Hof // Alte Plauener Straße 24 
    
    new_address_line = old_address_line   # default - do nothing - just path through
    
    lines = old_address_line.split( '//' )

    if lines.size == 2   # two lines / check for switching lines
      line1 = lines[0].strip
      line2 = lines[1].strip
      if line2 =~ /^[0-9]{5}\s/
        new_address_line = "#{line2} // #{line1}"   # swap - let line w/ 5-digit zip code go first
      end
    end
  
    new_address_line
  end

  def self.title_to_key( title )

      ## NB: downcase does NOT work for accented chars (thus, include in alternatives)
      key = title.downcase

      ## remove all whitespace and punctuation
      key = key.gsub( /[ \t_\-\.()\[\]'"\/]/, '' )

      ## remove special chars (e.g. %°&)
      key = key.gsub( /[%&°]/, '' )

      ##  turn accented char into ascii look alike if possible
      ##
      ## todo: add some more
      ## see http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references  for more
      
      ## todo: add unicode codepoint name
      
      alternatives = [
        ['ß', 'ss'],
        ['æ', 'ae'],
        ['ä', 'ae'],
        ['ā', 'a' ],  # e.g. Liepājas
        ['á', 'a' ],  # e.g. Bogotá, Králové
        ['ã', 'a' ],  # e.g  São Paulo
        ['ă', 'a' ],  # e.g. Chișinău
        ['â', 'a' ],  # e.g  Goiânia
        ['å', 'a' ],  # e.g. Vålerenga
        ['ą', 'a' ],  # e.g. Śląsk
        ['ç', 'c' ],  # e.g. São Gonçalo, Iguaçu, Neftçi
        ['ć', 'c' ],  # e.g. Budućnost
        ['č', 'c' ],  # e.g. Tradiční, Výčepní
        ['é', 'e' ],  # e.g. Vélez, Králové
        ['è', 'e' ],  # e.g. Rivières
        ['ê', 'e' ],  # e.g. Grêmio
        ['ě', 'e' ],  # e.g. Budějovice
        ['ĕ', 'e' ],  # e.g. Svĕtlý
        ['ė', 'e' ],  # e.g. Vėtra
        ['ë', 'e' ],  # e.g. Skënderbeu
        ['ğ', 'g' ],  # e.g. Qarabağ
        ['ì', 'i' ],  # e.g. Potosì
        ['í', 'i' ],  # e.g. Ústí
        ['ł', 'l' ],  # e.g. Wisła, Wrocław
        ['ñ', 'n' ],  # e.g. Porteño
        ['ň', 'n' ],  # e.g. Plzeň, Třeboň
        ['ö', 'oe'],
        ['ő', 'o' ],  # e.g. Győri
        ['ó', 'o' ],  # e.g. Colón, Łódź, Kraków
        ['õ', 'o' ],  # e.g. Nõmme
        ['ø', 'o' ],  # e.g. Fuglafjørdur, København
        ['ř', 'r' ],  # e.g. Třeboň
        ['ș', 's' ],  # e.g. Chișinău, București
        ['ş', 's' ],  # e.g. Beşiktaş
        ['š', 's' ],  # e.g. Košice
        ['ť', 't' ],  # e.g. Měšťan
        ['ü', 'ue'],
        ['ú', 'u' ],  # e.g. Fútbol
        ['ū', 'u' ],  # e.g. Sūduva
        ['ů', 'u' ],  # e.g. Sládkův
        ['ı', 'u' ],  # e.g. Bakı   # use u?? (Baku) why-why not?
        ['ý', 'y' ],  # e.g. Nefitrovaný
        ['ź', 'z' ],  # e.g. Łódź
        ['ž', 'z' ],  # e.g. Domžale, Petržalka

        ['Č', 'c' ],  # e.g. České
        ['İ', 'i' ],  # e.g. İnter
        ['Í', 'i' ],  # e.g. ÍBV
        ['Ł', 'l' ],  # e.g. Łódź
        ['Ö', 'oe' ], # e.g. Örebro
        ['Ř', 'r' ],  # e.g. Řezák
        ['Ś', 's' ],  # e.g. Śląsk
        ['Š', 's' ],  # e.g. MŠK
        ['Ş', 's' ],  # e.g. Şüvälan
        ['Ú', 'u' ],  # e.g. Ústí, Újpest
        ['Ž', 'z' ]   # e.g. Žilina
      ]
      
      alternatives.each do |alt|
        key = key.gsub( alt[0], alt[1] )
      end

      key
  end # method title_to_key

end # class Brewery


end # module BeerDb::Models
