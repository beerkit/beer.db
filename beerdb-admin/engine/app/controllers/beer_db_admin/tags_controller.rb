# encoding: utf-8

module BeerDbAdmin

class TagsController < BeerDbAdminController

  def index
    @beer_tags    = Tag.uniq.joins(:taggings).where("taggings.taggable_type='BeerDb::Models::Beer'").order('key').all
    @brewery_tags = Tag.uniq.joins(:taggings).where("taggings.taggable_type='BeerDb::Models::Brewery'").order('key').all
  end

end # class TagsController


end # module BeerDbAdmin
