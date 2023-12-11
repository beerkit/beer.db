# encoding: utf-8

module BeerDbAdmin

class BreweriesController < BeerDbAdminController
  
  def index
    order = params[:order] || 'title'

    if order == 'key'
      order_clause = 'key'
    elsif order == 'hl'
      order_clause = 'prod desc, title'
    else   # by_title
      order_clause = 'title'
    end
    
    # note:  show 25 per page for now

    @breweries = Brewery.limit(25).order( order_clause )
  end

  # GET /breweries/:id e.g. /breweries/1
  def show
    @brewery = Brewery.find( params[:id] )
  end

  # GET /by/:key  e.g  /by/guiness /by/ottakringer
  def shortcut
    @brewery = Brewery.find_by_key!( params[:key] )
    render :show
  end


end # class BreweriesController

end # module BeerDbAdmin
