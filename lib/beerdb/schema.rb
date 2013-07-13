# encoding: UTF-8

module BeerDb


### some more optional migrations
#
#  see beer.db.admin (copied for possible service/api version only)

class CreateDrinks < ActiveRecord::Migration

def up
  create_table :drinks do |t| # join table (user,beer)
    t.references :beer, :null => false
    t.references :user, :null => false
    t.integer :rating # 1-10 scala (10 is best)
    t.text :comments
    t.string :place # location (place) where tasted/drunken
      
    ## todo: add flag for bottle, can, draft
      
    t.timestamps
  end
end # method up

def down
  raise ActiveRecord::IrreversibleMigration
end

end # class CreateDrinks

class CreateBookmarks < ActiveRecord::Migration

def up
  create_table :bookmarks do |t| # join table (user,beer/brewery)
    t.references :bookmarkable, :polymorphic => true # todo: check add :null => false is possible/needed?
    t.references :user, :null => false
    t.boolean :yes, :null => false, :default => false # like/favorite/top
    t.boolean :no, :null => false, :default => false # dislike/flop/blacklisted
    t.boolean :wish, :null => false, :default => false # e.g wish == false == drunk / wishlist (beer not yet drunken/tasted)
      
    t.timestamps
  end
end # method up

def down
  raise ActiveRecord::IrreversibleMigration
end

end # class CreateBookmarks


class CreateUsers < ActiveRecord::Migration

def up
  create_table :users do |t|
    t.string :key, :null => false # import/export key
    t.string :name, :null => false
    t.string :email, :null => false
    t.boolean :admin, :null => false, :default => false
    t.boolean :guest, :null => false, :default => false
    t.boolean :active, :null => false, :default => true

    t.timestamps
  end
end # method up

def down
  raise ActiveRecord::IrreversibleMigration
end

end # class CreateUsers


#####################
# main migration

class CreateDb < ActiveRecord::Migration


def up

create_table :beers do |t|
  t.string  :key,   :null => false   # import/export key
  t.string  :title, :null => false
  t.string  :synonyms  # comma separated list of synonyms

  t.string  :web    # optional url link (e.g. )
  t.integer :since  # optional year (e.g. 1896)

  # t.boolean  :bottle,  :null => false, :default => false # Flaschenbier
  # t.boolean  :draft,   :null => false, :default => false # Fassbier
  ## todo: check seasonal is it proper english?
  t.boolean  :seasonal, :null => false, :default => false # all year or just eg. Festbier/Oktoberfest Special
  t.boolean  :limited, :null => false, :default => false   # one year or season only
  ## todo: add microbrew/brewpub flag?
  #### t.boolean  :brewpub, :null => false, :default => false
  
  ## add t.boolean :lite  flag ??
  t.decimal    :kcal    # kcal/100ml e.g. 45.0 kcal/100ml

  ## check: why decimal and not float? 
  t.decimal    :abv    # Alcohol by volume (abbreviated as ABV, abv, or alc/vol) e.g. 4.9 %
  t.decimal    :og     # malt extract (original gravity) in plato
  t.integer    :srm    # color in srm
  t.integer    :ibu    # bitterness in ibu

  ### fix/todo: add bitterness field

  # renamed - old field names
  ## t.decimal    :plato  # stammwuerze / gravity in plato scale (e.g. °P) e.g. 12.6°   - todo: use a different field name e.g. just p or gravity?
  ## t.integer    :color  # beer color in Standard Reference Method (SRM)

# see en.wikipedia.org/wiki/Plato_scale#Colour

# SRM/Lovibond  | Example  | Beer color  | EBC
# ---------------------------------------------------------------
# 2  | Pale lager, Witbier, Pilsener, Berliner Weisse  | #F8F753 | 4
# 3  | Maibock, Blonde Ale                             | #F6F513 | 6
# 4  | Weissbier                                       | #ECE61A | 8
# 6  | American Pale Ale, India Pale Ale               | #D5BC26 | 12
# 8  | Weissbier, Saison                               | #BF923B | 16
# 10  | English Bitter, ESB                            | #BF813A | 20
# 13  | Biere de Garde, Double IPA                     | #BC6733 | 26
# 17  | Dark lager, Vienna lager, Marzen, Amber Ale    | #8D4C32 | 33
# 20  | Brown Ale, Bock, Dunkel, Dunkelweizen          | #5D341A | 39
# 24  | Irish Dry Stout, Doppelbock, Porter            | #261716 | 47
# 29  | Stout                                          | #0F0B0A | 57
# 35  | Foreign Stout, Baltic Porter                   | #080707 | 69
# 40+  | Imperial Stout                                | #030403 | 79

  t.references :brewery   # optional (for now)
  t.references :brand     # optional (for now)


  ## todo: add categories e.g. (A/B/C, 1/2/3, main/major/minor ??)
  # - A-grade /1st class/ tier1 / main beer brand/bestseller/flagship ?
  # - B-grade /2nd class/ tier2 / regular, major,   - todo: find better names?
  # - C-grade /3nd class/ tier3/ / speciality, minor ?

  # use stars in .txt e.g. # ***/**/*/- => 1/2/3/4
  t.integer :grade, :null => false, :default => 4

  t.string  :txt            # source ref
  t.boolean :txt_auto, :null => false, :default => false     # inline? got auto-added?


  t.references :country,  :null => false
  t.references :region   # optional
  t.references :city     # optional

  t.timestamps
end


create_table :brands do |t|   # beer families (sharing same name e.g. brand)
  t.string  :key,   :null => false   # import/export key
  t.string  :title, :null => false
  t.string  :synonyms  # comma separated list of synonyms
  t.string  :web   # optional web page (e.g. www.ottakringer.at)
  t.string  :wiki  # optional wiki(pedia page)
  t.integer :since

  ## scope of brand (global/intern'l/national/regional/local) ??
  t.boolean :global,     :null => false, :default => false 
  t.boolean :internl,    :null => false, :default => false
  t.boolean :national,   :null => false, :default => false
  t.boolean :regional,   :null => false, :default => false
  t.boolean :local,      :null => false, :default => false

  # t.integer :brand_grade   # 1/2/3/4/5  (global/intern'l/national/regional/local)

  # use stars in .txt e.g. # ***/**/*/- => 1/2/3/4
  t.integer :grade, :null => false, :default => 4
  #   -- todo: add plus 1 for brewery w/ *** ??

  t.string  :txt            # source ref
  t.boolean :txt_auto, :null => false, :default => false     # inline? got auto-added?


  t.references :brewery   # optional (for now)

  t.references :country,   :null => false
  t.references :region   # optional
  t.references :city     # optional

  t.timestamps
end

create_table :breweries do |t|
  t.string  :key,   :null => false   # import/export key
  t.string  :title, :null => false
  t.string  :synonyms  # comma separated list of synonyms
  t.string  :address
  t.integer :since
  ## renamed to founded to since
  ## t.integer :founded  # year founded/established    - todo/fix: rename to since? 
  t.integer :closed  # optional;  year brewery closed

## todo: add optional parent brewery (owned_by)

  t.integer :prod  # (estimated) annual production/capacity in hl (1hl=100l) e.g. megabrewery 2_000_000, microbrewery 1_000 hl; brewbup 500 hl etc.
  t.integer :prod_grade   # 1/2/3/4/5/6/7/8/9/10/11

  # grade - classified using annual production (capacity) in hl
  # <     1_000 hl  => 11
  # <     3_000 hl  => 10
  # <     5_000 hl  => 9
  # <    10_000 hl  => 8
  # <    50_000 hl  => 7
  # <   100_000 hl  => 6
  # <   200_000 hl  => 5
  # <   500_000 hl  => 4
  # < 1_000_000 hl  => 3
  # < 2_000_000 hl  => 2
  # > 2_000_000 hl  => 1


  # use stars in .txt e.g. # ***/**/*/- => 1/2/3/4
  t.integer :grade, :null => false, :default => 4


  t.string  :txt            # source ref
  t.boolean :txt_auto, :null => false, :default => false     # inline? got auto-added?

  t.string  :web        # optional web page (e.g. www.ottakringer.at)
  t.string  :wikipedia  # optional wiki(pedia page)

  t.boolean :indie    # independent brewery (flag)

  # for convenience (easy queries) use flags for top beer multinationals (-- later use just tags? more flexible)
  t.boolean :abinbev     # owned by AB InBev / Anheuser-Busch InBev (and Grupo Modelo)
  t.boolean :sabmiller   # owned by SAB Miller (in US cooperates w/ Molson Coors using MillerCoors venture)
  t.boolean :heineken    # owned by Heineken
  t.boolean :carlsberg   # owned by Carlsberg
  t.boolean :molsoncoors  # owned by Molson Coors
  t.boolean :diageo       # owned by Diageo (e.g. Guiness, Kilkenny,...)


  # todo: add t.references :parent  # for parent brewery
  # (or better use has many parents w/ percentage of ownership; might not be 100%)

  t.references :country,   :null => false
  t.references :region   # optional
  t.references :city     # optional
  
  t.timestamps
end

end # method up

def down
  raise ActiveRecord::IrreversibleMigration
end


end # class CreateDb

end # module BeerDb