# encoding: UTF-8

module BeerDb

### some more optional migrations
#
#  see beer.db.admin (copied for possible service/api version only)


####
# tasting notes (w/ ratings)
class CreateDbExtrasNotes

def up
  ActiveRecord::Schema.define do
    create_table :notes do |t| # join table (user,beer)
      t.references :beer, :null => false
      t.references :user, :null => false
      t.integer :rating,  :null => false  # 1-10 scala (10 is best)

      t.text :comments
      t.string :place # location (place) where tasted/drunken

      ## todo: add flag for bottle, can, draft

      t.timestamps
    end
  end # Schema.define
end # method up
end # class CreateDbExtrasNotes


#################
# +1 - beer drink log; track beers
class CreateDbExtrasDrinks

def up
  ActiveRecord::Schema.define do
    create_table :drinks do |t| # join table (user,beer)
      t.references :beer, :null => false
      t.references :user, :null => false
      t.datetime   :drunk_at  ## , :null => false  # todo: pre-set if nil to created_at?

      t.string     :place # location (place) where tasted/drunken

      ## todo: add flag for bottle, can, draft

      t.timestamps
    end
  end # Schema.define
end # method up
end # class CreateDrinks


class CreateDbExtrasBookmarks

def up
  ActiveRecord::Schema.define do
    create_table :bookmarks do |t| # join table (user,beer/brewery)
      t.references :bookmarkable, :polymorphic => true # todo: check add :null => false is possible/needed?
      t.references :user, :null => false

      t.boolean :yes,  :null => false, :default => false # like/favorite/top
      t.boolean :no,   :null => false, :default => false # dislike/flop/blacklisted
      t.boolean :wish, :null => false, :default => false # e.g wish == false == drunk / wishlist (beer not yet drunken/tasted)

      t.timestamps
    end
  end # Schema.define
end # method up
end # class CreateBookmarks



class CreateDbExtrasUsers

def up
  ActiveRecord::Schema.define do
    create_table :users do |t|
      t.string  :key,    :null => false # import/export key
      t.string  :name,   :null => false
      t.string  :email,  :null => false
      t.boolean :admin,  :null => false, :default => false
      t.boolean :guest,  :null => false, :default => false
      t.boolean :active, :null => false, :default => true

      t.timestamps
    end
  end # Schema.define
end # method up
end # class CreateUsers

end # module BeerDb
