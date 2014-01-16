# encoding: utf-8


require 'helper'

### todo/fix: move to worlddb along with fixture matcher module!!

class TestFixtureMatchers < MiniTest::Unit::TestCase

  include BeerDb::Matcher


  def test_country

    beers_at = [
      'europe/at/beers',
      'europe/at-austria/beers',
      'at-austria/beers',
      'at-austria!/beers'
    ]

    beers_at.each do |name|
      found = match_beers_for_country( name ) do |country_key|
        assert( country_key == 'at')
      end
      assert( found == true )
    end

    breweries_at = [
      'europe/at/breweries',
      'europe/at-austria/breweries',
      'at-austria/breweries',
      'at-austria!/breweries'
    ]

    breweries_at.each do |name|
      found = match_breweries_for_country( name ) do |country_key|
        assert( country_key == 'at')
      end
      assert( found == true )
    end
  end # method test_country


  def test_country_n_region

    beers_at = [
      'europe/at-austria/w-wien/beers',
      'at-austria/w-wien/beers',
      'at-austria!/w-wien/beers'
    ]

    beers_at.each do |name|
      found = match_beers_for_country_n_region( name ) do |country_key,region_key|
        assert( country_key == 'at')
        assert( region_key  == 'w' )
      end
      assert( found == true )
    end

    breweries_at = [
      'europe/at-austria/w-wien/breweries',
      'at-austria/w-wien/breweries',
      'at-austria!/w-wien/breweries'
    ]

    breweries_at.each do |name|
      found = match_breweries_for_country_n_region( name ) do |country_key,region_key|
        assert( country_key == 'at')
        assert( region_key  == 'w' )
      end
      assert( found == true )
    end
  end # method test_country_n_region


end # class TestFixtureMatchers