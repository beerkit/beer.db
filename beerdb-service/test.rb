

class BeerDb::Model::Note < ActiveRecord::Base
  def as_json( opts={} )
     puts "  !!!! as_json_v2"
     data = {
       beer: { title:  beer.title,
               key:    beer.key },
       user: { name:   user.name,
               key:    user.key },
       rating:      rating,
       comments:    comments,
       place:       place,
       created_at:  created_at,
       updated_at:  updated_at
    }
    data
  end
end


get '/seed' do
  ## add some seed data

  puts "GET /seed"

  alois = User.create!( key:  'alois',
                name: 'Alois Mustermann',
                email: 'alois@example.com' )

  pp alois

  { status: 'ok' }
end

get '/seed2' do

  puts "GET /seed2"

  ## add random note
  user = User.first
  beer = Beer.rnd

  attribs = {
    user_id: user.id,
    beer_id: beer.id,
    rating:  3,
    place:   'Place Here'
  }

  note = Note.new
  note.update_attributes!( attribs )

  pp note

  { status: 'ok' }
end




get '/notes/(l|latest)' do  # get latest tasting notes (w/ ratings)
  Note.order( 'updated_at DESC' ).limit(10).all
end

get '/notes/(h|hot)' do  # get latest tasting notes (w/ ratings)
  # fix: use log algo for "hotness" - for now same as latest
  Note.order( 'updated_at DESC' ).limit(10).all
end

get '/notes/(t|top)' do
  Note.order( 'rating DESC, updated_at DESC' ).limit(10).all
end

get '/notes/:key' do
  ### todo: move to /u/:key/notes - why? why not??
  # assume it's a user key
  user = User.find_by!( key: params['key'] )
  notes = Note.order( 'rating DESC, updated_at DESC' ).where( user_id: user.id ).all
  notes
end

post '/hello' do
  puts "POST /hello"
  pp params
  ## NameError: uninitialized constant BeerDbService::CONTENT_TYPE
  ## NoMethodError: undefined method `headers' for #<Rack::Request:0x55dd498>
  ## pp request.headers
  pp request
  puts request['Content-Type']
  ## puts request.headers['Content-Type']

  data = request.body.read
  puts "request.body.read(1):"
  puts data

  puts "request.body.read(2):"
  puts request.body.read    ## note: can read body only once!!!

  puts "JSON.parse:"
  pp JSON.parse( data )

  { status: 'ok' }
end


post '/notes' do
  puts "POST /notes"
  pp params
  pp JSON.parse( request.body.read )

  user    = User.find_by!( key: params['user'] )
  beer    = Beer.find_by!( key: params['beer'] )
  rating = params['rating'].to_i
  place  = params['place']   # assumes for now a string or nil / pass through as is

  attribs = {
    user_id: user.id,
    beer_id: beer.id,
    rating:  rating,
    place:   place
  }

  note = Note.new
  note.update_attributes!( attribs )

  { status: 'ok' }
end


get '/drinks/:key' do |key|

  puts "  handle GET /drinks/:key"

  if ['l', 'latest'].include?( key )
     # get latest +1 drinks
     ## todo: order by drunk_at??
    drinks = Drink.order( 'updated_at DESC' ).limit(10).all
  else
    ### todo: move to /u/:key/drinks ??

    # assume it's a user key
    user = User.find_by_key!( key )
    drinks = Drink.order( 'updated_at DESC' ).where( user_id: user.id ).all
  end

  data = []
  drinks.each do |drink|
    data << {
       beer: { title:  drink.beer.title,
               key:    drink.beer.key },
       user: { name:   drink.user.name,
               key:    drink.user.key },
       place:       drink.place,
       drunk_at:    drink.drunk_at,
       created_at:  drink.created_at,
       updated_at:  drink.updated_at
    }
  end

  data
end


get '/drinks' do
  if params[:method] == 'post'

    puts "  handle GET /drinks?method=post"

    user = User.find_by_key!( params[:user] )
    beer = Beer.find_by_key!( params[:beer] )
    place  = params[:place]   # assumes for now a string or nil / pass through as is

    attribs = {
      user_id: user.id,
      beer_id: beer.id,
      place:   place
    }

    drink = Drink.new
    drink.update_attributes!( attribs )
  end

  { status: 'ok' }
end


## todo: add support for beer of the day, of the week, of the month, of the year?
##  /beer/day|d  | /beer/month|m  | beer/year|y ??
##
## add table daily_beer, weekly_beer, etc. ??

get '/beer/:key' do |key|

  if ['r', 'rnd', 'rand', 'random'].include?( key )
    # special key for random beer
    # Note: use .first (otherwise will get ActiveRelation not Model)
    beer = Beer.rnd.first
  else
    beer = Beer.find_by_key!( key )
  end
end


get '/brewery/:key' do |key|

  if ['r', 'rnd', 'rand', 'random'].include?( key )
    # special key for random brewery
    # Note: use .first (otherwise will get ActiveRelation not Model)
    brewery = Brewery.rnd.first
  else
    brewery = Brewery.find_by_key!( key )
  end
end



=begin

curl -i -X POST -H "Content-Type: application/json" -d "{\"key\":\"alois\"}" http://localhost:4567/hello
HTTP

Note: curl in windows needs double quotes (escape quotes in quotes) in json data


check: https://x-team.com/blog/how-to-create-a-ruby-api-with-sinatra/
       https://github.com/mwpastore/sinja

payload = JSON.parse(request.body.read)

The Rack contrib module Rack::PostBodyContentTypeParser will do this for you as well.
The Rack parameter hash is populated by deserializing the JSON data
provided in the request body when
the Content-Type is application/json.
See github.com/rack/rack-contrib

=end
