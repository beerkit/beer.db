# encoding: utf-8

module BeerDbAdmin

class SessionsController < BeerDbAdminController
  
  # GET /session/new
  def new
    @user = User.new
  end

  # POST /session
  def create

    ## remove whitespace and (.-+_) and downcase
    email = params[:user][:email]
    if email.blank?
      key = 'xxx'
    else
      key = email.gsub( /[\s\.\-+_]/, '' ).downcase
    end
    
    @user = User.find_by_key( key )
    
    if @user.present? && @user.active?

      session[:user_id] = @user.id
      flash[:notice] = 'Anmeldung erfolgreich.'
      
      redirect_to frontpage_path()
    else
      if @user.present?
        if @user.active == false
          flash.now[:error] = 'Konto gesperrt. Tut leid.'
        end
      else
        flash.now[:error] = 'Unbekannte Email. Tut leid.'
      end
      @user = User.new( params[:user] )
      render :action => 'new'
    end
  end


  # DELETE /session
  def destroy
    session[:user_id] = nil
    flash[:notice] = 'Tschüss.'
    redirect_to signin_path()
  end
end

end # module BeerDbAdmin
