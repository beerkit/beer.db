####
# e.g. use like
#   rake db:seed WORLD=f   or
#   rake db:seed WORLDDB=skip

skip_worlddb_str =  ENV['WORLD'] || ENV['WORLDDB']

if skip_worlddb_str.present? && ['f', 'false', 'skip'].include?( skip_worlddb_str )
  skip_worlddb = true
  puts 'skipping setup for world.db'
else
  skip_worlddb = false
end


LogDb.delete!
WorldDb.delete!  unless skip_worlddb    # danger zone! deletes all records
BeerDb.delete!  # danger zone! deletes all records



WorldDb.read_setup( 'setups/sport.db.admin', find_data_path_from_gemfile_gitref('world.db'), { skip_tags: true } )  unless skip_worlddb



beerdb_setups = []

beerdb_setups +=[
  ['world',                      'all'],
  ['de-deutschland',             'all'],
  ['at-austria',                 'all'],
  ['ch-confoederatio-helvetica', 'all'],
  ['cz-czech-republic',          'all'],
  ['be-belgium',                 'all'],
  ['nl-netherlands',             'all'],
  ['ie-ireland',                 'all'],
  ['ca-canada',                  'all'],
  ['us-united-states',           'all'],
  ['mx-mexico',                  'all'],
  ['jp-japan',                   'all']
]


beerdb_setups.each do |setup|
  BeerDb.read_setup( "setups/#{setup[1]}", find_data_path_from_gemfile_gitref( setup[0]) )
end

BeerDb.tables

puts 'Done. Bye.'

