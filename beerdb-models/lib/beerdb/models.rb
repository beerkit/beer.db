# encoding: utf-8


require 'worlddb/models'    # Note: pull in all required stdlibs n gems via worlddb/models


# our own code

require 'beerdb/version'   ## version always goes first

require 'beerdb/models/forward'
require 'beerdb/models/world/country'
require 'beerdb/models/world/state'
require 'beerdb/models/world/city'
require 'beerdb/models/tag'
require 'beerdb/models/beer'
require 'beerdb/models/brand'
require 'beerdb/models/brewery'

require 'beerdb/serializers/beer'
require 'beerdb/serializers/brewery'

require 'beerdb/readers/beer'
require 'beerdb/readers/brewery'
require 'beerdb/readers/quick'


require 'beerdb/schema'
require 'beerdb/reader'
require 'beerdb/reader_file'
require 'beerdb/reader_zip'
require 'beerdb/deleter'
require 'beerdb/stats'


module BeerDb


  def self.create
    CreateDb.new.up

    ### fix: make optional do NOT auto create here
    ### fix: use if defined? BeerDbNote or similar or/and check if table exist ??
    ###      or move to beerdb-note ??

    # CreateDbExtrasUsers.new.up
    # CreateDbExtrasBookmarks.new.up
    # CreateDbExtrasDrinks.new.up
    # CreateDbExtrasNotes.new.up

    ConfDb::Model::Prop.create!( key: 'db.schema.beer.version', value: VERSION )
  end

  ## convenience helper for all-in-one create for tables
  def self.create_all
    LogDb.create
    ConfDb.create
    TagDb.create
    WorldDb.create
    BeerDb.create
  end


  def self.read( ary, include_path )
    reader = Reader.new( include_path )
    ary.each do |name|
      reader.load( name )
    end
  end

  def self.read_setup( setup, include_path, opts={} )
    reader = Reader.new( include_path, opts )
    reader.load_setup( setup )
  end

  def self.read_setup_from_zip( zip_name, setup, include_path, opts={} )  ## todo/check - use a better (shorter) name ??
    reader = ZipReader.new( zip_name, include_path, opts )
    reader.load_setup( setup )
    reader.close
  end

  def self.read_all( include_path, opts={} )  # load all builtins (using plain text reader); helper for convenience
    read_setup( 'setups/all', include_path, opts )
  end # method read_all


  # delete ALL records (use with care!)
  def self.delete!
    puts '*** deleting beer table records/data...'
    Deleter.new.run
  end # method delete!

  def self.delete_all!( opts={} )
    # to be done
  end

  def self.tables
    Stats.new.tables
  end


end  # module BeerDb



# say hello
puts BeerDb.banner  if $DEBUG || (defined?($RUBYLIBS_DEBUG) && $RUBYLIBS_DEBUG)
