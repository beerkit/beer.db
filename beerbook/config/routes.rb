
Prost::Application.routes.draw do

  mount About::Server,     :at => '/sysinfo'
  mount DbBrowser::Server, :at => '/browse'

  ###
  # mount sinatra app (bundled w/ sportdb-service gem) for json api service

  # todo: add  JSON API link to layout

  get '/api' => redirect('/api/v1')
  mount BeerDb::Server, :at => '/api/v1' # NB: make sure to require 'beerdb/server' in env

  ## mount sinatra app (bundled w/ logutils gem)
  mount LogDb::Server, :at => '/logs'    # NB: make sure to require 'logutils/server' in env



  #############################
  # routes for mobile / m

  match 'm', :to => 'mobile/pages#home'

  namespace :mobile do
    match 'signin',  :to => 'sessions#new'
    match 'signout', :to => 'sessions#destroy'

    resource :session, :only => [:new, :create, :destroy]

    match 'time',   :to => 'time#index'

    match 'bookmarks/:id/flag', :to => 'bookmarks#update_flag', :as => 'update_bookmark_flag'

    resources :users
    resources :drinks
    resources :bookmarks
    resources :beers
  end


  #############
  # routes for admin

  match 'admin', :to => 'admin/users#index'
  
  namespace :admin do
    resources :users
  end


  mount BeerDbAdmin::Engine, :at => '/'  # mount a root possible?

=begin

FIX FIX FIX
 more routes from beer.db.admin eninge
 
  match 'signin', :to => 'sessions#new'
  match 'signout', :to => 'sessions#destroy'
  
  resource :session, :only => [:new, :create, :destroy]
  
  match 'time',   :to => 'time#index'

  # current user's start page/front page
  match 'frontpage', :to => 'frontpage#index'

  match 'users/:user_id/beers/:beer_id/drinks/new', :to => 'drinks#new', :as => 'new_user_beer_drink'

  match 'bookmarks/:id/flag', :to => 'bookmarks#update_flag', :as => 'update_bookmark_flag'

  resources :drinks
  resources :bookmarks 


  resources :users do
   ## resources :drinks
   ## resources :bookmarks
  end

=end

end