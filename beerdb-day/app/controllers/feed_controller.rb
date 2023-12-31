
class FeedController < ApplicationController

  def index
    @today = Date.today
    ## Note: older date MUST get listed before newer date (otherwise query will fail result in zero rows)
    @days  = Day.where( date: (@today-9.days)..@today ).order('date DESC')  # get 10 days (beers)

    render action: 'index.atom.builder',
           content_type: 'application/atom+xml',
           layout: false
  end

end  # class FeedController

