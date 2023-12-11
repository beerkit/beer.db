# encoding: utf-8

module BeerDbAdmin
module ServiceHelper


###
#
# todo/fix: move to its own gem for reuse and sharing ??  - why? why not?
#  - check alternatives - any?
#
#  - use open search xml spec ?? 
#


#####################
#  browse tags 

  def link_to_flickr_tags( tags, opts={} )   # fix: add alias for link_to_flickr_tag
    # e.g. use
    #  ottakringer
    #  ottakringer+beer    -- use plus for multiple tags
    link_to tags, "http://www.flickr.com/photos/tags/#{tags}", opts
  end

#########################
#  search terms (q)

  def link_to_flickr_search( q, opts={} )
     # e.g. use
     #   ottakringer
     #   ottakringer+beer    -- note: + is url encoded for space e.g. equals ottakringer beer
    link_to q, "http://www.flickr.com/search/?q=#{q}", opts
  end


  def link_to_google_search( q, opts={} )
    link_to q, "https://www.google.com/search?q=#{q}", opts
  end

  def link_to_google_de_search( q, opts={} )
    link_to q, "https://www.google.de/search?hl=de&q=#{q}", opts
  end


  def link_to_google_search_images( q, opts={} )
    link_to q, "https://www.google.com/search?tbm=isch&q=#{q}", opts
  end

  def link_to_bing_search_images( q, opts={} )
    link_to q, "http://www.bing.com/images/search?q=#{q}", opts
  end

  def link_to_wikipedia_search( q, opts={} )
    link_to q, "http://en.wikipedia.org/?search=#{q}", opts
  end

  def link_to_wikipedia_de_search( q, opts={} )
    link_to q, "http://de.wikipedia.org/?search=#{q}", opts
  end

  def link_to_untappd_search( q, opts={} )
    link_to q, "https://untappd.com/search?q=#{q}", opts
  end


end # module ServiceHelper
end # moudle BeerDbAdmin

