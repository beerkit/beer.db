# encoding: utf-8


get '/beer/(r|rnd|rand|random)' do     ## special keys for random beer
  Beer.rnd
end

get '/beer/:key' do 
  Beer.find_by! key: params['key']
end


get '/brewery/(r|rnd|rand|random)' do    ## special keys for random brewery
  Brewery.rnd
end

get '/brewery/:key' do
  Brewery.find_by! key: params['key']
end
