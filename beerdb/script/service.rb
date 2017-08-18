###
# test webservice

###
#  to run use
#     ruby script/service.rb

require 'webservice'

require 'beerdb/models'   # Note: pull in all required deps via beerdb-models



puts "working directory: #{Dir.pwd}"

BeerDb.connect( adapter: 'sqlite3',
                database: './beer.db' )

BeerDb.tables   ## print table stats



class BeerService < Webservice::Base
  include BeerDb::Models   # e.g. Beer, Brewery, Brand, etc.

  puts "hello from class BeerService"


  def self.hello
     puts "!!! hello from hello"

     pp Beer.count
     pp Beer.rnd
  end
end



def load_file( path )
    code = File.open( path, 'r:bom|utf-8' ).read

    app_class = Class.new( BeerService )
    app_class.instance_eval( code )  ## use class_eval ??
    app_class
end


## builder = Webservice::Builder.load_file( './script/service/starter.rb' )
## try to include BeerDb::Models
## builder.app_class.include BeerDb::Models

app_class = load_file( './script/service/starter.rb' )

puts "app_class:"
pp app_class

#############
# for testing startup server

puts "dump routes:"
pp app_class.routes

puts "starting server..."
app_class.run!
puts "bye"
