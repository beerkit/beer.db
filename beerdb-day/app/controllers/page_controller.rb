# encoding: utf-8

class PageController < ApplicationController

  def index

    if params[:date]
      ## note: allow 2015/01/01 and 2015.01.01
      @date = Date.strptime( params[:date].gsub(/[\/.]/, '-'), '%Y-%m-%d' )
    elsif params[ :day ]
      ## assume current year (plus add x days from Jan/1)
      @date = Date.new( Date.today.year,1,1 ) + (params[:day].to_i-1)
    else
      @date = Date.today
    end

    ## check if beer of day exists in db
    ##  if not creaty entry (always - use the same beer of the day as stored/recorded in db)
    day = Day.find_by_date( @date )

    if day.nil?
      ### todo: use self.rnd from activerecord-utils
      ## get random beer (of the day) for now

      rnd_offset = rand( Beer.count ) ## NB: call "global" std lib rand
      @beer = Beer.offset( rnd_offset ).limit( 1 ).first
      
      Day.create!( date: @date, beer: @beer )
    else
      @beer = day.beer
    end


    ## puts "day:   #{@date.day}"
    ## puts "month: #{@date.month}"
    ## puts "year:  #{@date.year}"
    ## puts "yday:  #{d.yday}"

    @date_monthname = Date::MONTHNAMES[@date.month]  ## e.g. January
    @date_dayname   = Date::DAYNAMES[@date.wday]  ## e.g. Sunday, Monday
    @date_week      = @date.strftime('%W').to_i+1 ## e.g. 1,2,3,etc.

  end

end

