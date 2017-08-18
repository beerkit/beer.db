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



class BeerDbService < Webservice::Base
  include BeerDb::Models   # e.g. Beer, Brewery, Brand, etc.

  puts "hello from class #{self.name}"


  def self.hello
     puts "hello from method self.hello"

     pp Beer.count
     pp Beer.rnd

     puts "[debug] hello self name:>#{self.name}< object_id:(#{self.object_id})"
  end
end



def read_code( path )
  File.open( path, 'r:bom|utf-8' ).read
end


code = read_code( './script/service/starter.rb' )

BeerDbService.class_eval( code )  ## note: MUST use class_eval (do NOT use instance_eval)  !!!

app_class = BeerDbService

puts "app_class:"
pp app_class
pp app_class.superclass

#############
# for testing startup server

puts "dump routes:"
pp app_class.routes

puts "starting server..."
app_class.run!
puts "bye"
