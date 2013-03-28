module BeerDb::Models

class Brewery < ActiveRecord::Base

  self.table_name = 'breweries'

  belongs_to :country, :class_name => 'WorldDb::Models::Country', :foreign_key => 'country_id'
  belongs_to :city,    :class_name => 'WorldDb::Models::City',    :foreign_key => 'city_id'

end # class Brewery


end # module BeerDb::Models

