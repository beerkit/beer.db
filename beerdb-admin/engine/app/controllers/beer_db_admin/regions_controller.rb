# encoding: utf-8

module BeerDbAdmin

class RegionsController < BeerDbAdminController
  
  def index
    @regions = Region.all
  end
  
  def show
    @region = Region.find( params[:id] )
  end

  def shortcut
    
    # todo/fix: check case if no key match; no country; no region etc.
    
    # split key into country key and region key
    if params[:key] =~ /([a-z]{2,3})[\-+.]([a-z]{1,3})/
      @country = Country.find_by_key( $1 )
      @region  = Region.find_by_country_id_and_key( @country.id, $2 )
    end

    render :show
  end
end # class RegionsController

end # module BeerDbAdmin
