
require 'fetcher'

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

WORLD_URL        = 'https://github.com/openmundi/world.db/archive/master.zip'
WORLD_ZIP_NAME   = 'world.db'
WORLD_ZIP  = "#{ZIP_PATH}/#{WORLD_ZIP_NAME}.zip"

AT_CTY_URL  = 'https://github.com/openmundi/austria.db/archive/master.zip'
AT_CTY_ZIP_NAME  = 'austria.db'
AT_CTY_ZIP = "#{ZIP_PATH}/#{AT_CTY_ZIP_NAME}.zip"


AT_BEER_URL  = 'https://github.com/openbeer/at-austria/archive/master.zip'
AT_BEER_ZIP_NAME  = 'at-austria'
AT_BEER_ZIP = "#{ZIP_PATH}/#{AT_BEER_ZIP_NAME}.zip"

BE_BEER_URL  = 'https://github.com/openbeer/be-belgium/archive/master.zip'
BE_BEER_ZIP_NAME  = 'be-belgium'
BE_BEER_ZIP = "#{ZIP_PATH}/#{BE_BEER_ZIP_NAME}.zip"


task :debug_tmp do
  puts "pwd:        >>#{Dir.pwd}<<"  ## for debugging - print current working directory
  puts "zip_path:   >>#{ZIP_PATH}<<"
  puts "Rails.root: >>#{Rails.root}<<"

  ## check if zip file exists
  puts "WORLD_ZIP    size: #{File.size(WORLD_ZIP)} bytes"   if File.exists?(WORLD_ZIP)
  puts "AT_BEER_ZIP  size: #{File.size(AT_BEER_ZIP)} bytes" if File.exists?(AT_BEER_ZIP)
  puts "BE_BEER_ZIP  size: #{File.size(BE_BEER_ZIP)} bytes" if File.exists?(BE_BEER_ZIP)
end


desc 'download world.db zip archive to /tmp/world.db.zip'
task :dl_world => [:debug_tmp] do
  dowload_archive( WORLD_URL, WORLD_ZIP )
end


task :dl_at do
  dowload_archive( AT_CTY_URL, AT_CTY_ZIP )
  dowload_archive( AT_BEER_URL, AT_BEER_ZIP )
end


task :dl_be do
  dowload_archive( BE_BEER_URL, BE_BEER_ZIP )
end


task :load_world => [:environment]  do
  LogDb.delete!
  ConfDb.delete!
  TagDb.delete!
  BeerDb.delete!
  WorldDb.delete!

  WorldDb.read_setup_from_zip( WORLD_ZIP_NAME, 'setups/sport.db.admin', ZIP_PATH, { skip_tags: true } )
end

task :load_at => [:environment]  do
  WorldDb.read_setup_from_zip( AT_CTY_ZIP_NAME, 'setups/all', ZIP_PATH, { skip_tags: true } )

  TagDb.delete!
  BeerDb.delete!  # danger zone! deletes all records
  
  BeerDb.read_setup_from_zip( AT_BEER_ZIP_NAME, 'setups/all', ZIP_PATH )
end


task :load_be => [:environment] do
  TagDb.delete!
  BeerDb.delete!  # danger zone! deletes all records

  BeerDb.read_setup_from_zip( BE_BEER_ZIP_NAME, 'setups/all', ZIP_PATH )
end

