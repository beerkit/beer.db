# encoding: utf-8

module BeerDbAdmin

class BookmarksController < BeerDbAdminController

  def update_flag

    bookmark = Bookmark.find( params[:id] )
    
    # check params
    if params[:yes].present?
      if params[:yes] == 'true' || params[:yes] == 't'
        bookmark.yes = true  # +1
        bookmark.no  = false
      else
        bookmark.yes = false
      end
    end
      
    if params[:no].present?
      if params[:no] == 'true' || params[:no] == 't'
        bookmark.no  = true  # -1
        bookmark.yes = false
      else  
        bookmark.no = false
      end
    end

    if params[:wish].present?
      if params[:wish] == 'true' || params[:wish] == 't'
        bookmark.wish = true
        bookmark.no    = false  # reset -1 flag if present
      else
        bookmark.wish = false
      end
    end

    flash[:notice] = 'Bookmark erfolgreich gespeichert.'
    bookmark.save!

    redirect_to :back
  end

end # class BookmarksController

end # module BeerDbAdmin