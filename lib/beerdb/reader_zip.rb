# encoding: UTF-8

module BeerDb




class ZipReader < ReaderBase


  ## todo/fix: add a close method - why? why not ???

  def initialize( zip_path, opts = {} )
    @zip_path = zip_path
    ## check if zip exists

    @zip_file = Zip::File.open( zip_path )   ## NOTE: do NOT create if file is missing; let it crash
  end

  def close
    @zip_file.close
  end


  def create_fixture_reader( name )
    FixtureReader.from_zip( @zip_file, name )
  end

  def create_beers_reader( name, more_attribs={} )
    ValuesReader.from_zip( @zip_file, name, more_attribs )
  end

  def create_breweries_reader( name, more_attribs={} )
    ValuesReader.from_zip( @zip_file, name, more_attribs )
  end


end # class ZipReader
end # module BeerDb

