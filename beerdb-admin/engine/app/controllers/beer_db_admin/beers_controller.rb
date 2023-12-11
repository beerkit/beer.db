# encoding: utf-8

module BeerDbAdmin

class BeersController < BeerDbAdminController
  
  def index
    # note: show 25 per page for now
    @beers = Beer.limit( 25 ).where( 'brewery_id is not null' )
  end
  
  # GET /beers/:id e.g. /beers/1
  def show
    @beer = Beer.find( params[:id] )
  end

  # GET /beer/:key  e.g  /beer/guiness /beer/ottakringerhelles
  def shortcut
    @beer = Beer.find_by_key!( params[:key] )
    render :show
  end

end # class BeersController

end # module BeerDbAdmin
