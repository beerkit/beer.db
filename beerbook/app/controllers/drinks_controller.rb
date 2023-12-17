# encoding: utf-8

module BeerDbAdmin

class DrinksController < BeerDbAdminController

  include ApplicationHelper   # fix: move current_user to application controller too

  # GET /drinks
  def index
  end

 # GET /drinks/new
  def new
     # NB: beer_id n current_user (user_id) required

     @drink = Drink.new
     @beer = Beer.find( params[:beer_id] )
     @user = current_user()  # assert user_id == current_user_id

     @drink.beer_id = @beer.id
     @drink.user_id = @user.id
  end

  # POST /drinks
  def create
    @drink = Drink.new(params[:drink])
    
    if @drink.save
      flash[:notice] = 'Drink erfolgreich gespeichert.'
      redirect_to frontpage_path()
    else
      @beer = @drink.beer
      @user = current_user()  # assert @drink.user_id == current_user_id
      render action: 'new'
    end
  end


  # GET /drinks/1/edit
  def edit
    @drink = Drink.find( params[:id] )
    @beer = @drink.beer
    @user = current_user()  # assert @drink.user_id == current_user_id
  end

  # PUT /drinks/1
  def update
    @drink = Drink.find( params[:id] )
    
    if @drink.update_attributes( params[:drink] )
      flash[:notice] = 'Drink erfolgreich gespeichert.'
      redirect_to frontpage_path()
    else
      @beer = @drink.beer
      @user = current_user()  # assert @drink.user_id == current_user_id
      render action: 'edit'
    end
  end

end # class DrinksController

end # module BeerDbAdmin
