# encoding: UTF-8

module BeerDb

class Reader < ReaderBase  ## todo: "old" classic reader - rename to FileReader ?? why? why not?

  attr_reader :include_path

  def initialize( include_path, opts = {} )
    @include_path = include_path
  end

  def create_fixture_reader( name )
    path = "#{include_path}/#{name}.txt"

    logger.info "parsing data '#{name}' (#{path})..."

    FixtureReader.new( path )
  end

  def create_beers_reader( name, more_attribs={} )
    ValuesReaderV2.new( name, include_path, more_attribs )
  end

  def create_breweries_reader( name, more_attribs={} )
    ValuesReaderV2.new( name, include_path, more_attribs )
  end


end # class Reader
end # module BeerDb
