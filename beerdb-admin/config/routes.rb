
Prost::Application.routes.draw do

  mount About::Server,     :at => '/sysinfo'
  mount DbBrowser::Server, :at => '/browse'

  ###
  # mount sinatra app (bundled w/ sportdb-service gem) for json api service

  # todo: add  JSON API link to layout
  if defined?( BeerDb::Server )
    get '/api' => redirect('/api/v1')
    mount BeerDb::Server, :at => '/api/v1' # NB: make sure to require 'beerdb/server' in env
  end

  ## mount sinatra app (bundled w/ logutils gem)
  mount LogDb::Server, :at => '/logs'    # NB: make sure to require 'logutils/server' in env


  mount BeerDbAdmin::Engine, :at => '/'  # mount a root possible?

end
