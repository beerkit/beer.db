###
# NB: for local testing run like:
#
# 1.9.x: ruby -Ilib lib/beerdb.rb

# core and stlibs

## stdlibs
# -- get required already by worlddb (remove ??)

require 'yaml'
require 'pp'
require 'logger'
require 'optparse'
require 'fileutils'
require 'erb'

# 3rd party gems / libs

#  -- get required by worlddb
# require 'active_record'   ## todo: add sqlite3? etc.
# require 'logutils'
# require 'textutils'

require 'worlddb'


# our own code

require 'beerdb/version'   ## version always goes first

require 'beerdb/models/forward'
require 'beerdb/models/world/country'
require 'beerdb/models/world/region'
require 'beerdb/models/world/city'
require 'beerdb/models/tag'
require 'beerdb/models/beer'
require 'beerdb/models/brand'
require 'beerdb/models/brewery'


require 'beerdb/serializers/beer'
require 'beerdb/serializers/brewery'

require 'beerdb/schema'
require 'beerdb/reader'
require 'beerdb/deleter'
require 'beerdb/stats'


module BeerDb

  def self.banner
    "beerdb #{VERSION} on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
  end

  def self.root
    "#{File.expand_path( File.dirname(File.dirname(__FILE__)) )}"
  end

  def self.main
    require 'beerdb/cli/main'
    # Runner.new.run(ARGV) old code
  end

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

  def self.read_all( include_path, opts={} )  # load all builtins (using plain text reader); helper for convenience
    read_setup( 'setups/all', include_path, opts )
  end # method read_all


  # delete ALL records (use with care!)
  def self.delete!
    puts '*** deleting beer table records/data...'
    Deleter.new.run
  end # method delete!

  def self.tables
    Stats.new.tables
  end


end  # module BeerDb


if __FILE__ == $0
  BeerDb.main
else
  # say hello
  puts BeerDb.banner
end