# encoding: utf-8

module BeerDbAdmin
module PartHelper


  def render_bookmarks( bookmarks, opts={} )

    render partial: 'beer_db_admin/shared/bookmarks',
           locals: { bookmarks: bookmarks,
                     allow_edits: (opts[:edit].present? ? true : false) }
  end



end # module PartHelper
end # module BeerDbAdmin