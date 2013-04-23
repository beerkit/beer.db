# encoding: UTF-8

module BeerDb

class CreateDb < ActiveRecord::Migration


def up

create_table :beers do |t|
  t.string  :key,   :null => false   # import/export key
  t.string  :title, :null => false
  t.string  :synonyms  # comma separated list of synonyms

  t.string  :web    # optional url link (e.g. )
  t.integer :since  # optional year (e.g. 1896)

  t.boolean  :bottle,  :null => false, :default => false # Flaschenbier
  t.boolean  :draft,   :null => false, :default => false # Fassbier
  ## todo: check seasonal is it proper english?
  t.boolean  :seasonal, :null => false, :default => false # all year or just eg. Festbier/Oktoberfest Special
  ## todo: add microbrew/brewpub flag?
  #### t.boolean  :brewpub, :null => false, :default => false
  
  ## add t.boolean :lite  flag ??
  t.decimal    :kcal    # kcal/100ml e.g. 45.0 kcal/100ml

  ## check: why decimal and not float? 
  t.decimal    :abv    # Alcohol by volume (abbreviated as ABV, abv, or alc/vol) e.g. 4.9 %
  t.decimal    :og     # malt extract (original gravity) in plato
  t.integer    :srm    # color in srm

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

  t.references :country,  :null => false
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

  t.integer :prod  # (estimated) annual production in hl (1hl=100l) e.g. megabrewery 2_000_000, microbrewery 1_000 hl; brewbup 500 hl etc.

  t.string  :web   # optional web page (e.g. www.ottakringer.at)

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