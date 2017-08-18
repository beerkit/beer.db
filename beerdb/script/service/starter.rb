# encoding: utf-8


hello()


get '/beer/:key' do |key|

  if ['r', 'rnd', 'rand', 'random'].include?( key )
    # special key for random beer
    beer = Beer.rnd
  else
    beer = Beer.find_by_key!( key )
  end
end


get '/brewery/:key' do |key|

  if ['r', 'rnd', 'rand', 'random'].include?( key )
    # special key for random brewery
    brewery = Brewery.rnd
  else
    brewery = Brewery.find_by_key!( key )
  end
end
