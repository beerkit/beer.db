# encoding: utf-8

module BeerDb

## todo: "old" classic reader - rename to FileReader ?? why? why not?

class Reader < ReaderBase  

  def initialize( include_path, opts = {} )
    @include_path = include_path
  end

  def create_fixture_reader( name )
    path = "#{@include_path}/#{name}.txt"

    logger.info "parsing data (setup) '#{name}' (#{path})..."

    FixtureReader.from_file( path )
  end

  def create_beers_reader( name, more_attribs={} )
    real_name = name_to_real_name( name )
    
    path = "#{@include_path}/#{real_name}.txt"

    logger.info "parsing data (beers) '#{name}' (#{path})..."

    BeerReader.from_file( path, more_attribs )
  end

  def create_breweries_reader( name, more_attribs={} )
    real_name = name_to_real_name( name )

    path = "#{@include_path}/#{real_name}.txt"

    logger.info "parsing data (breweries) '#{name}' (#{path})..."

    if name =~ /\(m\)/     # check for (m) mid-size/medium marker -todo- use $?? must be last?
       more_attribs[ :prod_m ] = true
    elsif name =~ /\(l\)/  # check for (l) large marker - todo - use $?? must be last?
       more_attribs[ :prod_l ] = true
    else
      ## no marker; do nothing
    end

    BreweryReader.from_file( path, more_attribs )
  end

private

  def name_to_real_name( name )
    # map name to real_name path
    # name might include !/ for virtual path (gets cut off)
    # e.g. at-austria!/w-wien/beers becomse w-wien/beers
    pos = name.index( '!/')
    if pos.nil?
      name # not found; real path is the same as name
    else
      # cut off everything until !/ e.g.
      # at-austria!/w-wien/beers becomes
      # w-wien/beers
      name[ (pos+2)..-1 ]
    end
  end

end # class Reader
end # module BeerDb

