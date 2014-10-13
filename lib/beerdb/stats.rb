# encoding: utf-8

module BeerDb

  class Stats
    include Models

    def tables
      puts "Stats:"
      puts " #{'%5d' % Beer.count} beers"
      puts " #{'%5d' % Brand.count} brands"
      puts " #{'%5d' % Brewery.count} breweries"
      puts

      ### fix: use if defined? BeerDbNote or similar or/and check if table exist ??
      ###      or move to beerdb-note ??
      
      # puts " #{'%5d' % User.count} users"         # db model extension - move to its own addon?
      # puts " #{'%5d' % Bookmark.count} bookmarks" # db model extension - move to its own addon?
      # puts " #{'%5d' % Drink.count} drinks"       # db model extension - move to its own addon?
      # puts " #{'%5d' % Note.count} notes"         # db model extension - move to its own addon?
    end

  end # class Stats

end # module BeerDb

