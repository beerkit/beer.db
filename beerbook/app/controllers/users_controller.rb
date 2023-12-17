# encoding: utf-8

module BeerDbAdmin

class UsersController < BeerDbAdminController
  
  include ApplicationHelper  # fix: move to ApplcationController current_user etc.
  
  def index
  end

  def show
    @user = User.find( params[:id] )
  end
  
  def edit
    @user = User.find( params[:id] )
  end

  def add_beer
    beer = Beer.find( params[:beer_id])
    # assert that params[:id] == current_user_id
    user = current_user()
    
    # check if bookmark exists; if not create it
    bookmark = Bookmark.find_by_bookmarkable_id_and_user_id( beer.id, user.id )
    if bookmark.nil?
      bookmark = Bookmark.new
      bookmark.user_id = user.id
      bookmark.bookmarkable_id   = beer.id
      bookmark.bookmarkable_type = 'BeerDb::Models::Beer'
      bookmark.save!
    end

    flash[:notice] = 'Bookmark erfolgreich gespeichert.'

    redirect_to :back
  end

  def add_brewery
    brewery = Brewery.find( params[:brewery_id])
    # assert that params[:id] == current_user_id
    user = current_user()
    
    brewery.beers.each do |beer|
      # check if bookmark exists; if not create it
      bookmark = Bookmark.find_by_bookmarkable_id_and_user_id( beer.id, user.id )
      if bookmark.nil?
        bookmark = Bookmark.new
        bookmark.user_id = user.id
        bookmark.bookmarkable_id   = beer.id
        bookmark.bookmarkable_type = 'BeerDb::Models::Beer'
        bookmark.save!
      end
    end

    flash[:notice] = "#{brewery.beers.count} Bookmarks erfolgreich gespeichert."

    redirect_to :back
  end

end # class UsersController


end # module BeerDbAdmin

