# encoding: utf-8

module BeerDb

  class Stats
    include BeerDb::Models

    def tables
      puts "Stats:"
      puts " #{'%5d' % Beer.count} beers"
      puts " #{'%5d' % Brand.count} brands"
      puts " #{'%5d' % Brewery.count} breweries"
    end
    
    def props
      puts "Props:"
      Prop.order( 'created_at asc' ).all.each do |prop|
        puts "  #{prop.key} / #{prop.value} || #{prop.created_at}"
      end
    end
  end # class Stats

end # module BeerDb