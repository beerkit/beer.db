
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
