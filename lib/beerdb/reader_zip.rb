# encoding: UTF-8

module BeerDb


class ZipReader < ReaderBase

  def initialize( name, include_path, opts = {} )

    ## todo/fix: make include_path an opts (included in opts?) - why? why not??

    path = "#{include_path}/#{name}.zip"
    ## todo: check if zip exists

    @zip_file = Zip::File.open( path )   ## NOTE: do NOT create if file is missing; let it crash
    
    ### allow prefix (path) in name
    ###    e.g. assume all files relative to setup manifest
    ## e.g. at-austria-master/setups/all.txt or
    ##      be-belgium-master/setups/all.txt
    ##  for
    ##    setups/all.txt
    ###
    ##  will get (re)set w/ fixture/setup reader
    ##
    ## todo/fix: change/rename to @relative_path ?? - why? why not? 
    @zip_prefix = ''
  end


  def close
    ## todo/check: add a close method - why? why not ???
    @zip_file.close
  end


  def create_fixture_reader( name )
    ## e.g. pass in =>  setups/all  or setups/test etc.  e.g. w/o .txt extension
    query = "**/#{name}.txt"

    ## note: returns an array of Zip::Entry
    candidates = @zip_file.glob( query )
    pp candidates

    ## use first candidates entry as match
    ## todo/fix: issue warning if more than one entries/matches!!

    ## get fullpath e.g. at-austria-master/setups/all.txt
    path = candidates[0].name
    logger.debug "  zip entry path >>#{path}<<"

    ## cut-off at-austria-master/    NOTE: includes trailing slash (if present)
    ## logger.debug "  path.size #{path.size} >>#{path}<<"
    ## logger.debug "  name.size #{name.size+4} >>#{name}<<"

    ## note: add +4 for extension (.txt)
    @zip_prefix = path[ 0...(path.size-(name.size+4)) ]
    logger.debug "  zip entry prefix >>#{@zip_prefix}<<"

    logger.info "parsing data in zip '#{name}' (#{path})..."

    FixtureReader.from_zip( @zip_file, path )
  end


  def create_beers_reader( name, more_attribs={} )
    path = name_to_zip_entry_path( name )

    logger.debug "parsing data (beers) in zip '#{name}' (#{path})..."

    ValuesReader.from_zip( @zip_file, path, more_attribs )
  end

  def create_breweries_reader( name, more_attribs={} )
    path = name_to_zip_entry_path( name )

    logger.debug "parsing data (breweries) in zip '#{name}' (#{path})..."

    ValuesReader.from_zip( @zip_file, path, more_attribs )
  end

private

  def path_to_real_path( path )
    # map name to name_real_path
    # name might include !/ for virtual path (gets cut off)
    # e.g. at-austria!/w-wien/beers becomse w-wien/beers
    pos = path.index( '!/')
    if pos.nil?
      path # not found; real path is the same as name
    else
      # cut off everything until !/ e.g.
      # at-austria!/w-wien/beers becomes
      # w-wien/beers
      path[ (pos+2)..-1 ]
    end
  end

  def name_to_zip_entry_path( name )
    path = "#{name}.txt"

    real_path = path_to_real_path( path )

    # NOTE: add possible zip entry prefix path
    #          (if present includes trailing slash e.g. /)
    entry_path = "#{@zip_prefix}#{real_path}"
    entry_path
  end


end # class ZipReader
end # module BeerDb
