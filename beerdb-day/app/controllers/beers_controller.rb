
class BeersController < ApplicationController

  def index
    @beers = Beer.order(:id)
  end

end
