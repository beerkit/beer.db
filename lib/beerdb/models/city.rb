module WorldDb::Models

class City
    has_many :beers,     :class_name => 'BeerDb::Models::Beer',    :foreign_key => 'country_id'
    has_many :breweries, :class_name => 'BeerDb::Models::Brewery', :foreign_key => 'country_id'
end # class Country

end # module WorldDb::Models
