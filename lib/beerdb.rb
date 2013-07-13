###
# NB: for local testing run like:
#
# 1.9.x: ruby -Ilib lib/beerdb.rb

# core and stlibs

require 'yaml'
require 'pp'
require 'logger'
require 'optparse'
require 'fileutils'
require 'erb'

# 3rd party gems / libs

require 'active_record'   ## todo: add sqlite3? etc.

require 'logutils'
require 'textutils'
require 'worlddb'


# our own code

require 'beerdb/version'

require 'beerdb/models/forward'
require 'beerdb/models/country'
require 'beerdb/models/region'
require 'beerdb/models/city'
require 'beerdb/models/tag'
require 'beerdb/models/beer'
require 'beerdb/models/brand'
require 'beerdb/models/brewery'
require 'beerdb/models/user'      # db model extensions - move to its own addon gem?
require 'beerdb/models/drink'     # db model extensions - move to its own addon gem?
require 'beerdb/models/bookmark'  # db model extensions - move to its own addon gem?
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
    CreateUsers.new.up
    CreateBookmarks.new.up
    CreateDrinks.new.up

    BeerDb::Models::Prop.create!( key: 'db.schema.beer.version', value: VERSION )
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

  def self.props
    Stats.new.props
  end

end  # module BeerDb


if __FILE__ == $0
  BeerDb.main
else
  # say hello
  puts BeerDb.banner
end