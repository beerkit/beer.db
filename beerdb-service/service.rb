# encoding: utf-8


get '/' do

  ## self-docu in json
  data = {
    endpoints: {
      get_beer: {
        doc: 'get beer by key',
        url: '/beer/:key'
      },
    }
  }

end


get '/notes/:key' do |key|

  puts "  handle GET /notes/:key"

  if ['l', 'latest'].include?( key )
     # get latest tasting notes (w/ ratings)
    notes = Note.order( 'updated_at DESC' ).limit(10).all
  elsif ['h', 'hot'].include?( key )
     # get latest tasting notes (w/ ratings)
     # fix: use log algo for "hotness" - for now same as latest
    notes = Note.order( 'updated_at DESC' ).limit(10).all
  elsif ['t', 'top'].include?( key )
    notes = Note.order( 'rating DESC, updated_at DESC' ).limit(10).all
  else
    ### todo: move to /u/:key/notes ??

    # assume it's a user key
    user = User.find_by_key!( key )
    notes = Note.order( 'rating DESC, updated_at DESC' ).where( user_id: user.id ).all
  end

  data = []
  notes.each do |note|
    data << {
       beer: { title:  note.beer.title,
               key:    note.beer.key },
       user: { name:   note.user.name,
               key:    note.user.key },
       rating:      note.rating,
       comments:    note.comments,
       place:       note.place,
       created_at:  note.created_at,
       updated_at:  note.updated_at
    }
  end

  data
end


get '/notes' do
  if params[:method] == 'post'

    puts "  handle GET /notes?method=post"

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

    note = Note.new
    note.update_attributes!( attribs )
  end

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
