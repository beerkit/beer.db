# encoding: utf-8

###
#  to run use
#     ruby -I ./lib -I ./test test/test_extras.rb
#  or better
#     rake test

require 'helper'


class TestExtras < MiniTest::Test

  def test_create

    BeerDb::CreateDbExtrasNotes.new.up
    BeerDb::CreateDbExtrasDrinks.new.up
    BeerDb::CreateDbExtrasBookmarks.new.up
    BeerDb::CreateDbExtrasUsers.new.up

    assert true  # for now everything ok if we get here
  end

end # class TestExtras
