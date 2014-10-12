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

######################
# fix begin:


################
# todo: move module to textutils!!!

### fix: move to textutils??


## todo: rename to  TitleHelpers? TitleMatcher? TitleMapper? TitleMapping? TitleMappings? TitleFinder? TitleHelpers?
#   or rename to KeyMapping?, KeyMapper?, KeyTable? etc.


module TextUtils::TitleTable


def build_title_table_for( records )
    ## build known tracks table w/ synonyms e.g.
    #
    # [[ 'wolfsbrug', [ 'VfL Wolfsburg' ]],
    #  [ 'augsburg',  [ 'FC Augsburg', 'Augi2', 'Augi3' ]],
    #  [ 'stuttgart', [ 'VfB Stuttgart' ]] ]

    known_titles = []

    records.each_with_index do |rec,index|

      title_candidates = []
      title_candidates << rec.title

      title_candidates += rec.synonyms.split('|') if rec.synonyms.present?


      ## check if title includes subtitle e.g. Grand Prix Japan (Suzuka Circuit)
      #  make subtitle optional by adding title w/o subtitle e.g. Grand Prix Japan

      titles = []
      title_candidates.each do |t|
        titles << t
        if t =~ /\(.+\)/
          extra_title = t.gsub( /\(.+\)/, '' ) # remove/delete subtitles
          extra_title.strip!   # strip leading n trailing withspaces too!
          titles << extra_title
        end
      end


      ## NB: sort here by length (largest goes first - best match)
      #  exclude code and key (key should always go last)
      titles = titles.sort { |left,right| right.length <=> left.length }
      
      ## escape for regex plus allow subs for special chars/accents
      titles = titles.map { |title| TextUtils.title_esc_regex( title )  }

      ## NB: only include code field - if defined
      titles << rec.code          if rec.respond_to?(:code) && rec.code.present?

      known_titles << [ rec.key, titles ]

      ### fix: use plain logger
      LogUtils::Logger.root.debug "  #{rec.class.name}[#{index+1}] #{rec.key} >#{titles.join('|')}<"
    end

    known_titles
end



def find_key_for!( name, line )
  regex = /@@oo([^@]+?)oo@@/     # e.g. everything in @@ .... @@ (use non-greedy +? plus all chars but not @, that is [^@])

  upcase_name   = name.upcase
  downcase_name = name.downcase

  if line =~ regex
    value = "#{$1}"
    ### fix: use plain logger
    LogUtils::Logger.root.debug "   #{downcase_name}: >#{value}<"
      
    line.sub!( regex, "[#{upcase_name}]" )

    return $1
  else
    return nil
  end
end


def find_keys_for!( name, line )  # NB: keys (plural!) - will return array
  counter = 1
  keys = []

  downcase_name = name.downcase

  key = find_key_for!( "#{downcase_name}#{counter}", line )
  while key.present?
    keys << key
    counter += 1
    key = find_key_for!( "#{downcase_name}#{counter}", line )
  end

  keys
end


def map_titles_for!( name, line, title_table )
  title_table.each do |rec|
    key    = rec[0]
    values = rec[1]
    map_title_worker_for!( name, line, key, values )
  end
end


def map_title_worker_for!( name, line, key, values )

  downcase_name = name.downcase

  values.each do |value|
    ## nb: \b does NOT include space or newline for word boundry (only alphanums e.g. a-z0-9)
    ## (thus add it, allows match for Benfica Lis.  for example - note . at the end)

    ## check add $ e.g. (\b| |\t|$) does this work? - check w/ Benfica Lis.$
    regex = /\b#{value}(\b| |\t|$)/   # wrap with world boundry (e.g. match only whole words e.g. not wac in wacker) 
    if line =~ regex
      ### fix: use plain logger
      LogUtils::Logger.root.debug "     match for #{downcase_name}  >#{key}< >#{value}<"
      # make sure @@oo{key}oo@@ doesn't match itself with other key e.g. wacker, wac, etc.
      line.sub!( regex, "@@oo#{key}oo@@ " )    # NB: add one space char at end
      return true    # break out after first match (do NOT continue)
    end
  end
  return false
end



end # module TextUtils::TitleTable



## auto-include methods

module TextUtils
  # make helpers available as class methods e.g. TextUtils.convert_unicode_dashes_to_plain_ascii
  extend TitleTable  # lets us use TextUtils.build_title_table_for etc.
end

# quich fix end:
########################



# our own code

require 'beerdb/version'   ## version always goes first

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
require 'beerdb/models/note'      # db model extensions - move to its own addon gem?


## add backwards compatible namespace
##  todo: move to forward -- check sportdb/worlddb convention ??
module BeerDb
  Models = Model
end


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
    CreateDbExtrasUsers.new.up
    CreateDbExtrasBookmarks.new.up
    CreateDbExtrasDrinks.new.up
    CreateDbExtrasNotes.new.up

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

  ###
  # fix: (re)use ConfDb.props
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