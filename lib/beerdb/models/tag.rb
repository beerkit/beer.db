
module WorldDb::Models

class Tag
  has_many :beers,     :through => :taggings, :source => :taggable, :source_type => 'BeerDb::Models::Beer',    :class_name => 'BeerDb::Models::Beer'
  has_many :breweries, :through => :taggings, :source => :taggable, :source_type => 'BeerDb::Models::Brewery', :class_name => 'BeerDb::Models::Brewery'
end # class Country

end # module WorldDb::Models
