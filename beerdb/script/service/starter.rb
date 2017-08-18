# encoding: utf-8


hello()


puts "[debug] eval (top) self name:>#{self.name}< object_id:(#{self.object_id})"

get '/hello' do

  puts "[debug] eval (get /hello) self.class name:>#{self.class.name}< object_id:(#{self.class.object_id})"

  data = { text: 'hello' }
  data
end


get '/test' do

  puts "[debug] eval (get /test) self.class name:>#{self.class.name}< object_id:(#{self.class.object_id})"

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


get '/beer/:key' do

  if ['r', 'rnd', 'rand', 'random'].include?( params['key'] )
    # special key for random beer
    beer = Beer.rnd
  else
    beer = Beer.find_by_key!( params['key'] )
  end
end


get '/brewery/:key' do

  if ['r', 'rnd', 'rand', 'random'].include?( params['key'] )
    # special key for random brewery
    brewery = Brewery.rnd
  else
    brewery = Brewery.find_by_key!( params['key'] )
  end
end
