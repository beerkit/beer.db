
desc "beerdb: stats/debug"
task :beerdb_stats => [:environment] do |t|
  puts "[debug] BeerDb.banner: >>#{BeerDb.banner}<<"
  puts "[debug] BeerDb.root: >>#{BeerDb.root}<<"

  BeerDb.tables
end



desc "beerdb: load beers/breweries"
task :beerdb_load => [:environment] do |t|

  # to be done

end