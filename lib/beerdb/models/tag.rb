module WorldDb::Model

class Tag
  has_many :beers,     :through => :taggings, :source => :taggable, :source_type => 'BeerDb::Model::Beer',    :class_name => 'BeerDb::Model::Beer'
  has_many :breweries, :through => :taggings, :source => :taggable, :source_type => 'BeerDb::Model::Brewery', :class_name => 'BeerDb::Model::Brewery'
end # class Country

end # module WorldDb::Model
