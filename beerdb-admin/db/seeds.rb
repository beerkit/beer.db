require 'fetcher'


####
# e.g. use like
# rake db:seed DL=f or
# rake db:seed DOWNLOAD=f|skip

skip_download_str = ENV['DL'] || ENV['DOWNLOAD']
if skip_download_str.present? && ['f', 'false', 'skip'].include?( skip_download_str )
  skip_download = true
  puts '*** skipping downloading zips'
else
  skip_download = false
end

skip_world_str =  ENV['WORLD'] || ENV['WORLDDB']
if skip_world_str.present? && ['f', 'false', 'skip'].include?( skip_world_str )
  skip_world = true
  puts '*** skipping setup for world.db'
else
  skip_world = false
end



####
# download tasks for zips

def dowload_archive( url, dest )
  puts "downloading #{url} to #{dest}..."
  worker = Fetcher::Worker.new
  worker.copy( url, dest )

  ## print some file stats
  puts "size: #{File.size(dest)} bytes"
end


ZIP_PATH    = "#{Rails.root}/tmp"

WORLD_NAME  = 'world.db'
WORLD_URL   = "https://github.com/openmundi/#{WORLD_NAME}/archive/master.zip"
WORLD_ZIP   = "#{ZIP_PATH}/#{WORLD_NAME}.zip"

AT_CTY_NAME  = 'austria.db'
AT_CTY_URL  = "https://github.com/openmundi/#{AT_CTY_NAME}/archive/master.zip"
AT_CTY_ZIP = "#{ZIP_PATH}/#{AT_CTY_NAME}.zip"




def debug_tmp
  puts "pwd:        >>#{Dir.pwd}<<"  ## for debugging - print current working directory
  puts "zip_path:   >>#{ZIP_PATH}<<"
  puts "Rails.root: >>#{Rails.root}<<"

  ## check if zip file exists
  puts "WORLD_ZIP    size: #{File.size(WORLD_ZIP)} bytes"   if File.exists?(WORLD_ZIP)
  puts "AT_CTY_ZIP   size: #{File.size(AT_CTY_ZIP)} bytes" if File.exists?(AT_CTY_ZIP)
end


def dl_world
  dowload_archive( WORLD_URL, WORLD_ZIP )
end

def dl_at
  dowload_archive( AT_CTY_URL, AT_CTY_ZIP )
end


def load_world
  # NOTE: assume env (database connection) is setup
  
  LogDb.delete!
  ConfDb.delete!
  TagDb.delete!
  WorldDb.delete!

  WorldDb.read_setup_from_zip( WORLD_NAME, 'setups/sport.db.admin', ZIP_PATH, { skip_tags: true } )
  WorldDb.read_setup_from_zip( AT_CTY_NAME, 'setups/all', ZIP_PATH, { skip_tags: true } )
end


def dl_beers( name )
  zip_url  = "https://github.com/openbeer/#{name}/archive/master.zip"
  zip_path = "#{ZIP_PATH}/#{name}.zip"

  dowload_archive( zip_url, zip_path )
end


beerdb_setups = []

beerdb_setups +=[
#  ['world',                      'all'],
#  ['de-deutschland',             'all'],
  ['at-austria',                 'all'],
#  ['ch-confoederatio-helvetica', 'all'],
  ['cz-czech-republic',          'all'],
  ['be-belgium',                 'all'],
#  ['nl-netherlands',             'all'],
#  ['ie-ireland',                 'all'],
#  ['ca-canada',                  'all'],
#  ['us-united-states',           'all'],
#  ['mx-mexico',                  'all'],
#  ['jp-japan',                   'all']
]



#####
# download and import datasets

debug_tmp()

if skip_world == false
  if skip_download == false
    dl_world()
    dl_at()
  end
  load_world()
end


if skip_download == false
  beerdb_setups.each do |setup|
  
    dl_beers( setup[0] )
    ## BeerDb.read_setup( "setups/#{setup[1]}", find_data_path_from_gemfile_gitref( setup[0]) )
  end
end

beerdb_setups.each do |setup|
  TagDb.delete!
  BeerDb.delete!  # danger zone! deletes all records
  BeerDb.read_setup_from_zip( setup[0], "setups/#{setup[1]}", ZIP_PATH )
end

debug_tmp()

puts 'Done. Bye.'

