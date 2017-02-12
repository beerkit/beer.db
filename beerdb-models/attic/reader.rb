
 def load_old_depreciated( name )
    ## remove - why?? why not??
    if name =~ /\.hl$/   # e.g. breweries.hl   # NB: must end w/ .hl
       load_brewery_prod( name )
    elsif name =~ /\/([a-z]{2})\.wikipedia/   # e.g. de.wikipedia
       # auto-add required lang e.g. de or en etc.
       load_brewery_wikipedia( $1, name )
    else
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


  def load_beers_worker( name, more_attribs={} )

    reader = create_beers_reader( name, more_attribs )  ### "virtual" method - required by concrete class

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

  def load_breweries_worker( name, more_attribs={} )
    
    if name =~ /\(m\)/     # check for (m) mid-size/medium marker -todo- use $?? must be last?
       more_attribs[ :prod_m ] = true
    elsif name =~ /\(l\)/  # check for (l) large marker - todo - use $?? must be last?
       more_attribs[ :prod_l ] = true
    else
      ## no marker; do nothing
    end

    reader = create_breweries_reader( name, more_attribs ) ### "virtual" method - required by concrete class

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

