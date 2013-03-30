module BeerDb::Models

class Beer < ActiveRecord::Base

  belongs_to :country, :class_name => 'WorldDb::Models::Country', :foreign_key => 'country_id'
  belongs_to :region,  :class_name => 'WorldDb::Models::Region',  :foreign_key => 'region_id'
  belongs_to :city,    :class_name => 'WorldDb::Models::City',    :foreign_key => 'city_id'

  belongs_to :brewery, :class_name => 'BeerDb::Models::Brewery',  :foreign_key => 'brewery_id'

end # class Beer


end # module BeerDb::Models

