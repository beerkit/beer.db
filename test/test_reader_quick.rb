# encoding: utf-8

###
#  to run use
#     ruby -I ./lib -I ./test test/test_reader_quick.rb
#  or better
#     rake test

require 'helper'


class TestReaderQuick < MiniTest::Test

  def setup
    #  delete all beers, brands, breweries in in-memory only db
    BeerDb.delete!
  end

  def test_reader

    reader = BeerDb::QuickReader.from_file( "#{BeerDb.root}/test/data/great-beers-europe.txt")
    reader.read()

    assert true
  end

end # class TestReaderQuick
