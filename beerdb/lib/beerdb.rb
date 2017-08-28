# encoding: utf-8


require 'beerdb/models'   # Note: pull in all required deps via beerdb-models
require 'beerdb/note'     # add extension/addon for notes etc.

require 'webservice'

require 'fetcher'
require 'datafile'

require 'gli'

# our own code

require 'beerdb/cli/version'   ## version always goes first
require 'beerdb/cli/opts'
require 'beerdb/cli/main'


module BeerDb

  def self.main
    exit Tool.new.run(ARGV)
  end

end  # module BeerDb



####
##  used for server/service command
##   "preconfigured" base class for webservice
class BeerDbService < Webservice::Base
  include BeerDb::Models   # e.g. Beer, Brewery, Brand, etc.

  ## (auto-)add some (built-in) routes

  get '/version(s)?' do
    {
      "beerdb":        BeerDbTool::VERSION,
      "beerdb/models": BeerDb::VERSION,
      ## todo/fix: add beerdb/note version - if present
      ## todo/fix: add worlddb/models version
      ## todo/fix: add some more libs - why? why not??
      "activerecord":  [ActiveRecord::VERSION::MAJOR,ActiveRecord::VERSION::MINOR,ActiveRecord::VERSION::TINY].join('.'),
      "webservice":    Webservice::VERSION,
      "rack":          "#{Rack::RELEASE} (#{Rack::VERSION.join('.')})",     ## note: VERSION is the protocoll version as an array e.g.[1,2]
      "ruby":          "#{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]",
    }
  end

  get '/(stats|tables)' do
    {
      "beers":      BeerDb::Model::Beer.count,
      "brands":     BeerDb::Model::Brand.count,
      "breweries":  BeerDb::Model::Brewery.count,
      "system": {
        "props":    ConfDb::Models::Prop.count,
        "logs":     LogDb::Models::Log.count,
      }
    }
  end

  get '/props(.:format)?' do    # note: add format - lets you use props.csv and props.html
    ConfDb::Models::Prop.all
  end

  get '/logs(.:format)?' do
    LogDb::Models::Log.all
  end
end



BeerDb.main  if __FILE__ == $0
