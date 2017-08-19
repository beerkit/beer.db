# encoding: utf-8


hello()


puts "[debug] eval (top) self = #<#{self.name}:#{self.object_id}>"

get '/hello' do

  puts "[debug] eval (get /hello) self.class = #<#{self.class.name}:#{self.class.object_id}>"

  data = { text: 'hello' }
  data
end


get '/test' do

  puts "[debug] eval (get /test) self.class = #<#{self.class.name}:#{self.class.object_id}>"

  pp Beer.count

  data = { text: 'test' }
  data
end

get '/t1' do
   beer = Beer.first
   pp beer
   beer
end

get '/t2' do
  beer = Beer.rnd
  pp beer
  beer
end

get '/t3' do
  beer = Beer.find_by_key!( 'egereredelpils' )
  pp beer
  beer
end


get '/beer/(r|rnd|rand|random)' do   # special keys for random beer
  Beer.rnd
end

get '/beer/:key' do
  Beer.find_by!( key: params['key'] )
end


get '/brewery/(r|rnd|rand|random)' do   # special keys for random brewery
  Brewery.rnd
end

get '/brewery/:key' do
  Brewery.find_by!( key: params['key'] )
end
