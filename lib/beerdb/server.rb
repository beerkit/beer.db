######
# NB: use rackup to startup Sinatra service (see config.ru)
#
#  e.g. config.ru:
#   require './boot'
#   run BeerDb::Server


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

  ## todo: add support for beer of the day, of the week, of the month, of the year?
  ##  /beer/day|d  | /beer/month|m  | beer/year|y ??
  ##
  ## add table daily_beer, weekly_beer, etc. ??

  get '/beer/:key' do |key|

    if ['r', 'rnd', 'rand', 'random'].include?( key )
      # special key for random beer
      beer = Beer.rnd
    else
      beer = Beer.find_by_key!( key )
    end

    brewery = {}
    if beer.brewery.present?
      brewery = { key: beer.brewery.key,
                  title: beer.brewery.title }
    end

    tags = []
    if beer.tags.present?
      beer.tags.each { |tag| tags << tag.key }
    end

    country = {
      key:   beer.country.key,
      title: beer.country.title
    }

    data = { key: beer.key, title: beer.title, synonyms: beer.synonyms,
                     abv: beer.abv, srm: beer.srm, og: beer.og,
                     tags: tags,
                     brewery: brewery,
                     country: country }

    json_or_jsonp( data )
  end


  get '/brewery/:key' do |key|

    if ['r', 'rnd', 'rand', 'random'].include?( key )
      # special key for random brewery
      brewery = Brewery.rnd
    else
      brewery = Brewery.find_by_key!( key )
    end


    beers = []
    brewery.beers.each do |b|
      beers << { key: b.key, title: b.title }
    end

    tags = []
    if brewery.tags.present?
      brewery.tags.each { |tag| tags << tag.key }
    end

    country = {
      key:   brewery.country.key,
      title: brewery.country.title
    }

    data = {  key: brewery.key,
              title: brewery.title,
              synonyms: brewery.synonyms,
              since: brewery.since,
              address: brewery.address,
              web: brewery.web,
              prod: brewery.prod,  # (estimated) annual production in hl e.g. 2_000 hl
              tags: tags,
              beers: beers,
              country: country }

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
