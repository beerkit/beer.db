# encoding: utf-8

module BeerDbAdmin

class CountriesController < BeerDbAdminController
  
  def index
    # list by continent
  end


  # GET /:key  e.g  /at or /us etc.
  def shortcut

    order = params[:order] || 'title'

    if order == 'key'
      @order_clause = 'key'
    elsif order == 'hl'
      @order_clause = 'prod desc, title'
    elsif order == 'adr'
      @order_clause = 'address, title'
    else   # by_title
      @order_clause = 'title'
    end
    
    @country = Country.find_by_key!( params[:key] )
    
    style = params[:style] || 'std'
    
    if style == 'pocket'
      render :show_pocket
    else
      render :show
    end
  end

  # GET /countries/:id  e.g. /countries/1
  def show
    @country = Country.find( params[:id] )
  end


end # class CountriesController

end # module BeerDbAdmin

