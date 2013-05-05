
module WorldDb::Models

class Region
    has_many :beers,     :class_name => 'BeerDb::Models::Beer',    :foreign_key => 'region_id'
    has_many :brands,    :class_name => 'BeerDb::Models::Brand',   :foreign_key => 'region_id'
    has_many :breweries, :class_name => 'BeerDb::Models::Brewery', :foreign_key => 'region_id'
end # class Region

end # module WorldDb::Models
