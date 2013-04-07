######
# NB: use rackup to startup Sinatra service (see config.ru)
#
#  e.g. config.ru:
#   require './boot'
#   run LogDb::Server


# 3rd party libs/gems

require 'sinatra/base'


# our own code


# require 'logutils'
# require 'logutils/db'



module BeerDb

class Server < Sinatra::Base

  def self.banner
    "beerdb-service #{BeerDb::VERSION} on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}] on Sinatra/#{Sinatra::VERSION} (#{ENV['RACK_ENV']})"
  end

  PUBLIC_FOLDER = "#{BeerDb.root}/lib/beerdb/server/public"
  VIEWS_FOLDER  = "#{BeerDb.root}/lib/beerdb/server/views"

  puts "[debug] beerdb-service - setting public folder to: #{PUBLIC_FOLDER}"
  puts "[debug] beerdb-service - setting views folder to: #{VIEWS_FOLDER}"
  
  set :public_folder, PUBLIC_FOLDER   # set up the static dir (with images/js/css inside)   
  set :views,         VIEWS_FOLDER    # set up the views dir

  set :static, true   # set up static file routing

  #####################
  # Models

  include BeerDb::Models

  ##################
  # Helpers
  
    helpers do
      def path_prefix
        request.env['SCRIPT_NAME']
      end
    end 

  ##############################################
  # Controllers / Routing / Request Handlers

  get '/' do
    erb :index
  end

  get '/d*' do
    erb :debug
  end

  get '/beer/:key' do |key|
    beer = Beer.find_by_key!( key )

    brewery = {}
    if beer.brewery.present?
      brewery = { key: beer.brewery.key, title: beer.brewery.title }
    end

    data = { beer: { key: beer.key, title: beer.title, abv: beer.abv, srm: beer.color, og: beer.plato },
             brewery: brewery }

    json_or_jsonp( data )
  end


  get '/brewery/:key' do |key|
    brewery = Brewery.find_by_key!( key )

    beers = []
    brewery.beers.each do |b|
      beers << { key: b.key, title: b.title  }
    end

    data = { brewery: { key: brewery.key, title: brewery.title }, beers: beers }

    json_or_jsonp( data )
  end


### helper for json or jsonp response (depending on callback para)

private
def json_or_jsonp( data )
  callback = params.delete('callback')
  response = ''

  if callback
    content_type :js
    response = "#{callback}(#{data.to_json})"
  else
    content_type :json
    response = data.to_json
  end
  
  response
end


end # class Server
end #  module BeerDb


# say hello
puts BeerDb::Server.banner
