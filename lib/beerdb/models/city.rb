module WorldDb::Models

### fix: use Model (not Models)

class City
    has_many :beers,     :class_name => 'BeerDb::Model::Beer',    :foreign_key => 'city_id'
    has_many :brands,    :class_name => 'BeerDb::Model::Brand',   :foreign_key => 'city_id'
    has_many :breweries, :class_name => 'BeerDb::Model::Brewery', :foreign_key => 'city_id'
end # class Country

end # module WorldDb::Models

