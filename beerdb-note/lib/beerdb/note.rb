# encoding: utf-8

###
# note: it's an addon to beerdb (get all libs via beerdb)
require 'beerdb'


# our own code

require 'beerdb/note/version' # let it always go first

require 'beerdb/note/models/forward'
require 'beerdb/note/models/user'
require 'beerdb/note/models/drink'
require 'beerdb/note/models/bookmark'
require 'beerdb/note/models/note'




module BeerDbNote

  def self.banner
    "beerdb-note/#{VERSION} on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
  end

  def self.root
    "#{File.expand_path( File.dirname( File.dirname(File.dirname(__FILE__))) )}"
  end

end # module BeerDbNote


puts BeerDbNote.banner   # say hello

