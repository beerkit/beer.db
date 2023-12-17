

class Mobile::DrinksController < Mobile::BaseController

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

     ### fix: add bookmarkable_type too = 'BeerDb::Model::Beer'
     @bookmark = Bookmark.find_by_user_id_and_bookmarkable_id( @user.id, @beer.id )

     @drink.beer_id = @beer.id
     @drink.user_id = @user.id
  end

  # POST /drinks
  def create
    @drink = Drink.new(params[:drink])
    
    if @drink.save
      flash[:notice] = 'Drink erfolgreich gespeichert.'
      ### fix: add bookmarkable_type too = 'BeerDb::Model::Beer'
      bookmark = Bookmark.find_by_user_id_and_bookmarkable_id( @drink.user_id, @drink.beer_id )
      redirect_to mobile_bookmark_path( bookmark.id )
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

    ### fix: add bookmarkable_type too = 'BeerDb::Model::Beer'
    @bookmark = Bookmark.find_by_user_id_and_bookmarkable_id( @user.id, @beer.id )

  end

  # PUT /drinks/1
  def update
    @drink = Drink.find( params[:id] )
    
    if @drink.update_attributes( params[:drink] )
      flash[:notice] = 'Drink erfolgreich gespeichert.'
      ### fix: add bookmarkable_type too = 'BeerDb::Model::Beer'
      bookmark = Bookmark.find_by_user_id_and_bookmarkable_id( @drink.user_id, @drink.beer_id )
      redirect_to mobile_bookmark_path( bookmark.id )
    else
      @beer = @drink.beer
      @user = current_user()  # assert @drink.user_id == current_user_id
      render action: 'edit'
    end
  end

end # class Mobile::DrinksController