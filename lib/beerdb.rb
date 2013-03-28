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


### fix: add to cli only - why? why not?
require 'logutils/db'   # add LogDb utils too


# our own code

require 'beerdb/version'

require 'beerdb/models/forward'
require 'beerdb/models/country'
require 'beerdb/models/city'
require 'beerdb/models/beer'
require 'beerdb/models/brewery'
require 'beerdb/schema'       # NB: requires beerdb/models (include BeerDB::Models)
require 'beerdb/cli/opts'
require 'beerdb/cli/runner'


module BeerDb

  def self.banner
    "beerdb #{VERSION} on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
  end

  def self.root
    "#{File.expand_path( File.dirname(File.dirname(__FILE__)) )}"
  end

  def self.main
    Runner.new.run(ARGV)
  end

  def self.create
    CreateDb.new.up
    BeerDb::Models::Prop.create!( key: 'db.schema.beer.version', value: VERSION )
  end

end  # module BeerDb


BeerDb.main if __FILE__ == $0