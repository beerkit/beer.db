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

     puts "[debug] hello self = #<#{self.name}:#{self.object_id}>"
  end
end



code = File.read_utf8( './script/service/starter.rb' )

BeerDbService.class_eval( code )  ## note: MUST use class_eval (do NOT use instance_eval)  !!!

#############
# for testing startup server

puts "dump routes:"
pp BeerDbService.routes

puts "starting server..."
BeerDbService.run!
puts "bye"
