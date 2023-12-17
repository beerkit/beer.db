
class Mobile::BookmarksController < Mobile::BaseController

  def index
  end

  def show
    @bookmark = Bookmark.find( params[:id] )
  end


end # class Mobile::BookmarksController
