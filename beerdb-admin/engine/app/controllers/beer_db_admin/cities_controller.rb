# encoding: utf-8

module BeerDbAdmin

class CitiesController < BeerDbAdminController

  def index
    @cities = City.all
  end

  def show
    @city = City.find( params[:id] )
  end


  def shortcut
    # todo/fix: check if city key is unique ? or needs country or region??
  
    @city = City.find_by_key!( params[:key] )

    render :show
  end
end # class CitiesController

end # module BeerDbAdmin
