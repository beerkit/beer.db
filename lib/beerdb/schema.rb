
module BeerDb

class CreateDb < ActiveRecord::Migration


def up

create_table :beers do |t|
  t.string  :title, :null => false
  t.string  :key,   :null => false   # import/export key
  t.string  :synonyms  # comma separated list of synonyms
  t.boolean  :bottle,  :null => false, :default => false # Flaschenbier
  t.boolean  :draft,   :null => false, :default => false # Fassbier
  ## todo: check seasonal is it proper english?
  t.boolean  :seasonal, :null => false, :default => false # all year or just eg. Festbier/Oktoberfest Special
  ## todo: add microbrew/brewpub flag?
  #### t.boolean  :brewpub, :null => false, :default => false
  
  t.references :country,  :null => false
  t.references :city  # optional 
  
  t.timestamps
end


create_table :breweries do |t|
  t.string  :title
  t.string  :key,   :null => false   # import/export key
  t.string  :synonyms  # comma separated list of synonyms
  t.references :country,   :null => false
  t.references :city  # optional
  
  t.timestamps
end

end # method up

def down
  raise ActiveRecord::IrreversibleMigration
end


end # class CreateDb

end # module BeerDb