# encoding: utf-8


require 'helper'


class TestFixtureMatchers < MiniTest::Unit::TestCase

  include WorldDb::Matcher
  include BeerDb::Matcher


  def test_country

    beers_at = [
      'europe/at/beers',
      'europe/at-austria/beers',
      'at-austria/beers',
      'at-austria!/beers',
      '1--at-austria--central/beers',
      'europe/1--at-austria--central/beers'
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
      'at-austria!/breweries',
      '1--at-austria--central/breweries',
      'europe/1--at-austria--central/breweries'
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
      'at-austria!/w-wien/beers',
      '1--at-austria--central/1--w-wien--eastern/beers',
      'europe/1--at-austria--central/1--w-wien--eastern/beers'
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
      'at-austria!/w-wien/breweries',
      '1--at-austria--central/1--w-wien--eastern/breweries',
      'europe/1--at-austria--central/1--w-wien--eastern/breweries'
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