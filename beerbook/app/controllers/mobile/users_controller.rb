
class Mobile::UsersController < Mobile::BaseController

  def index
  end

  def show
    @user = User.find( params[:id] )
  end
  
  def edit
    @user = User.find( params[:id] )
  end


end # class Mobile::UsersController
