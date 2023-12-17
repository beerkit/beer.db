# encoding: utf-8

module BeerDbAdmin

class FrontpageController < BeerDbAdminController

  include ApplicationHelper

  def index
    redirect_to user_path( current_user_id() )
  end

end # class FrontpageController

end # module BeerDbAdmin
