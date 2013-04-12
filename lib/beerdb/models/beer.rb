module BeerDb::Models

class Beer < ActiveRecord::Base

  belongs_to :country, :class_name => 'WorldDb::Models::Country', :foreign_key => 'country_id'
  belongs_to :region,  :class_name => 'WorldDb::Models::Region',  :foreign_key => 'region_id'
  belongs_to :city,    :class_name => 'WorldDb::Models::City',    :foreign_key => 'city_id'

  belongs_to :brewery, :class_name => 'BeerDb::Models::Brewery',  :foreign_key => 'brewery_id'

  has_many :taggings, :as => :taggable, :class_name => 'WorldDb::Models::Tagging'
  has_many :tags,  :through => :taggings, :class_name => 'WorldDb::Models::Tag'


  ### support old names (read-only) for now  (remove later)

  def color
    srm
  end

  def plato
    og
  end

  def color=(value)
    self.srm = value
  end

  def plato=(value)
    self.og = value
  end

end # class Beer


end # module BeerDb::Models
