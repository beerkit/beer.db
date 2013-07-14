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

  get '/drinks/:key' do |key|

    puts "  handle GET /drinks/:key"

    if ['l', 'latest'].include?( key )
       # get latest drinks (w/ ratings)
      drinks = Drink.order( 'updated_at DESC' ).limit(10).all
    elsif ['t', 'top'].include?( key )
      drinks = Drink.order( 'rating DESC, updated_at DESC' ).limit(10).all
    else
      # assume it's a user key
      user = User.find_by_key!( key )
      drinks = Drink.order( 'rating DESC, updated_at DESC' ).where( user_id: user.id ).all
    end

    data = []
    drinks.each do |drink|
      data << {
         beer: { title:  drink.beer.title,
                 key:    drink.beer.key },
         rating:      drink.rating,
         user: { name:   drink.user.name,
                 key:    drink.user.key },
         comments:    drink.comments,
         place:       drink.place,
         created_at:  drink.created_at,
         updated_at:  drink.updated_at
      }
    end
    
    json_or_jsonp( data.to_json )
  end


  get '/drinks' do
    if params[:method] == 'post'
      
      puts "  handle GET /drinks?method=post"
      
      user = User.find_by_key!( params[:user] )
      beer = Beer.find_by_key!( params[:beer] )
      rating = params[:rating].to_i
      place  = params[:place]   # assumes for now a string or nil / pass through as is

      attribs = {
        user_id: user.id,
        beer_id: beer.id,
        rating:  rating,
        place:   place
      }
      
      drink = Drink.new
      drink.update_attributes!( attribs )
    end

    json_or_jsonp( { status: 'ok' }.to_json )
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
      # NB: use .first (otherwise will get ActiveRelation not Model)
      beer = Beer.rnd.first
    else
      beer = Beer.find_by_key!( key )
    end

    json_or_jsonp( beer.as_json_v2 )
  end


  get '/brewery/:key' do |key|

    if ['r', 'rnd', 'rand', 'random'].include?( key )
      # special key for random brewery
      # NB: use .first (otherwise will get ActiveRelation not Model)
      brewery = Brewery.rnd.first
    else
      brewery = Brewery.find_by_key!( key )
    end

    json_or_jsonp( brewery.as_json_v2 )
  end


### helper for json or jsonp response (depending on callback para)

private
def json_or_jsonp( json )
  callback = params.delete('callback')
  response = ''

  if callback
    content_type :js
    response = "#{callback}(#{json})"
  else
    content_type :json
    response = json
  end
  
  response
end


end # class Server
end #  module BeerDb


# say hello
puts BeerDb::Server.banner
