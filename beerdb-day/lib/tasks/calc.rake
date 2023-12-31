
task :calc => [:environment]  do

  ## add all beers of the days for this year and year+1
  Day.delete_all    ## change to BeerDay ??
 
  today = Date.today
  ## year  = today.year

  date = today - 100   ## go back 100 days (from today)

  500.times do |i|  ## calc 500 days for now

    ### todo: use self.rnd from activerecord-utils
    ## get random beer (of the day) for now

    ## todo: make sure all beers get drawn (avoid duplicates)

    rnd_offset = rand( Beer.count ) ## NB: call "global" std lib rand
    beer = Beer.offset( rnd_offset ).limit( 1 ).first
    
    puts "[#{i}] #{date} -- #{beer.title}"
    
    Day.create!( date: date, beer: beer )
    date = date + 1
  end


    ## puts "day:   #{@date.day}"
    ## puts "month: #{@date.month}"
    ## puts "year:  #{@date.year}"
    ## puts "yday:  #{d.yday}"
end

