# encoding: utf-8

######
# note: to run use
#
#    $ ruby ./server.rb


class StarterApp < Webservice::Base

  #####################
  # Models

  include BeerDb::Models


  ##############################################
  # Controllers / Routing / Request Handlers

  # try special (reserved) keys for random beer first
  get '/beer/(r|rnd|rand|random)' do
    Beer.rnd
  end

  get '/beer/:key' do
    Beer.find_by! key: params[ 'key' ]
  end


  # try special (reserved) keys for random brewery first
  get '/brewery/(r|rnd|rand|random)' do
    Brewery.rnd
  end

  get '/brewery/:key' do
    Brewery.find_by! key: params[ 'key' ]
  end

end # class StarterApp
