module WorldDb::Models

class City
    has_many :beers,     :class_name => 'BeerDb::Models::Beer',    :foreign_key => 'city_id'
    has_many :brands,    :class_name => 'BeerDb::Models::Brand',   :foreign_key => 'city_id'
    has_many :breweries, :class_name => 'BeerDb::Models::Brewery', :foreign_key => 'city_id'
end # class Country

end # module WorldDb::Models
