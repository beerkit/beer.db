# encoding: utf-8

require 'bundler'
Bundler.setup    ## will setup $LOAD_PATH to get locked down gem version (see Gemfile.lock)

require 'pp'     ## fyi: pp is pretty printer

puts '$LOAD_PATH:'
pp $LOAD_PATH



ENV['RACK_ENV'] ||= 'development'

puts "ENV['RACK_ENV'] = #{ENV['RACK_ENV']}"


# 3rd party libs/gems

require 'webservice'    ## note: webservice will pull in web server machinery (e.g. rack)

require 'beerdb/models'   ## note: beerdb will pull in active record


DB_CONFIG = {
  adapter:  'sqlite3',
  database: 'beer.db'
}

puts 'DB_CONFIG:'
pp DB_CONFIG
ActiveRecord::Base.establish_connection( DB_CONFIG )


## for debugging - disable for production use
ActiveRecord::Base.logger = Logger.new( STDOUT )


require './app'
