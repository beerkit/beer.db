module BeerDb::Models

class Beer < ActiveRecord::Base

  belongs_to :country, :class_name => 'WorldDb::Models::Country', :foreign_key => 'country_id'
  belongs_to :city,    :class_name => 'WorldDb::Models::City',    :foreign_key => 'city_id'

end # class Beer


end # module BeerDb::Models

