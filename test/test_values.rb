# encoding: utf-8

###
#  to run use
#     ruby -I ./lib -I ./test test/test_helper.rb
#  or better
#     rake test

require 'helper'

class TestValues < MiniTest::Unit::TestCase

  def setup
    #  delete all beers, brands, breweries in in-memory only db
    BeerDb.delete!
  end

  def test_load_beer_values
    
    new_attributes = {
      key: 'ottakringerpur',
      title: 'Ottakringer (Gold Fassl) Pur {Bio}',
      synonyms: '',
      country_id: AT.id
    }

    values = [
      '5.2 %',
      '11.8°',
      'bio'
    ]
    
    beer = Beer.create_or_update_from_values( new_attributes, values )
    
    beer2 = Beer.find_by_key!( new_attributes[:key] )
    assert( beer.id == beer2.id )

    assert( beer.title         == new_attributes[:title] )
    assert( beer.country_id    == AT.id )
    assert( beer.country.title == AT.title )
    assert( beer.abv           == 5.2 )
    assert( beer.og            == 11.8 )
    assert( beer.srm           == nil )
  end

  def test_load_brewery_values

    # ottakringer, Ottakringer Brauerei, 1838, www.ottakringer.at, WI, city:wien, 1160 Wien // Ottakringer Platz 1
    #   brands: Ottakringer

    new_attributes = {
      key: 'ottakringer',
      title: 'Ottakringer Brauerei',
      synonyms: '',
      country_id: AT.id
    }

    values = [
      '1838',
      'www.ottakringer.at',
      '1160 Wien // Ottakringer Platz 1',
      'brands: Ottakringer'
    ]
    
    by = Brewery.create_or_update_from_values( new_attributes, values )

    by2 = Brewery.find_by_key!( new_attributes[:key] )
    assert( by.id == by2.id )

    assert( by.title         == new_attributes[:title] )
    assert( by.country_id    == AT.id )
    assert( by.country.title == AT.title )
    assert( by.since         == 1838 )
    assert( by.web           == 'www.ottakringer.at' )
    assert( by.address       == '1160 Wien // Ottakringer Platz 1' )

    # check auto-created brand

    br = Brand.find_by_key!( 'ottakringer')

    assert( br.title         == 'Ottakringer' )
    assert( br.brewery_id    == by.id )
    assert( br.brewery.title == by.title )
    assert( br.country_id    == by.country_id )
  end


  def test_load_brewery_values_w_city_at

    # ottakringer, Ottakringer Brauerei, 1838, www.ottakringer.at, WI, city:wien, 1160 Wien // Ottakringer Platz 1
    #   brands: Ottakringer

    new_attributes = {
      key: 'ottakringer',
      title: 'Ottakringer Brauerei',
      synonyms: '',
      country_id: AT.id,
      region_id: W.id
    }

    values = [
      '1838',
      'www.ottakringer.at',
      '1160 Wien // Ottakringer Platz 1',
      'brands: Ottakringer'
    ]
    
    by = Brewery.create_or_update_from_values( new_attributes, values )

    by2 = Brewery.find_by_key!( new_attributes[:key] )
    assert( by.id == by2.id )

    assert( by.title         == new_attributes[:title] )
    assert( by.country_id    == AT.id )
    assert( by.country.title == AT.title )
    assert( by.since         == 1838 )
    assert( by.web           == 'www.ottakringer.at' )
    assert( by.address       == '1160 Wien // Ottakringer Platz 1' )

    # check auto-created brand

    br = Brand.find_by_key!( 'ottakringer')

    assert( br.title         == 'Ottakringer' )
    assert( br.brewery_id    == by.id )
    assert( br.brewery.title == by.title )
    assert( br.country_id    == by.country_id )
    
    # todo: check for auto-created city
    assert( by.city.title == 'Wien' )
  end


  def test_load_brewery_values_w_city_de

    # hofbraeu, Hofbräu München, 1589, www.hofbraeu-muenchen.de, 81829 München // Hofbräuallee 1 

    new_attributes = {
      key: 'hofbraeu',
      title: 'Hofbräu München',
      synonyms: '',
      country_id: DE.id,
      region_id: BY.id
    }

    values = [
      '1589',
      'www.hofbraeu-muenchen.de',
      '81829 München // Hofbräuallee 1',
      'brands: Hofbräu'
    ]
    
    by = Brewery.create_or_update_from_values( new_attributes, values )

    by2 = Brewery.find_by_key!( new_attributes[:key] )
    assert( by.id == by2.id )

    assert( by.title         == new_attributes[:title] )
    assert( by.country_id    == DE.id )
    assert( by.country.title == DE.title )
    assert( by.since         == 1589 )
    assert( by.web           == 'www.hofbraeu-muenchen.de' )
    assert( by.address       == '81829 München // Hofbräuallee 1' )

    # tood: check auto-created brand
    # todo: check for auto-created city
    assert( by.city.title    == 'München' )

  end

end # class TestValues
