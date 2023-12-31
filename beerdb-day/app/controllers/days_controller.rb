
class DaysController < ApplicationController

  def index
    @days = Day.order( 'date DESC' )
  end

end

