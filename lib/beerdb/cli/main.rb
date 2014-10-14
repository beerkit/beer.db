# encoding: utf-8

require 'gli'
 
include GLI::App


require 'logutils/db'   # add support for logging to db
require 'beerdb/cli/opts'



program_desc 'beer.db command line tool'
version BeerDb::VERSION


LogUtils::Logger.root.level = :info   # set logging level to info 
logger = LogUtils::Logger.root


opts = BeerDb::Opts.new


### global option (required)
## todo: add check that path is valid?? possible?

desc 'Database path'
arg_name 'PATH'
default_value opts.db_path
flag [:d, :dbpath]

desc 'Database name'
arg_name 'NAME'
default_value opts.db_name
flag [:n, :dbname]

desc '(Debug) Show debug messages'
switch [:verbose], negatable: false    ## todo: use -w for short form? check ruby interpreter if in use too?

desc 'Only show warnings, errors and fatal messages'
switch [:q, :quiet], negatable: false



def connect_to_db( options )
  puts BeerDb.banner

  puts "working directory: #{Dir.pwd}"

  db_config = {
    :adapter  => 'sqlite3',
    :database => "#{options.db_path}/#{options.db_name}"
  }

  puts "Connecting to db using settings: "
  pp db_config

  ActiveRecord::Base.establish_connection( db_config )
  
  LogDb.setup  # turn on logging to db
end


desc 'Create DB schema'
command [:create] do |c|

  c.desc 'Extra tables (notes,drinks,marks,users)'
  c.switch [:extras], negatable: false 

  c.action do |g,o,args|

    connect_to_db( opts )

    if o[:extras].present?
      # quick hack: only create extra tables
      BeerDb::CreateDbExtrasUsers.new.up
      BeerDb::CreateDbExtrasBookmarks.new.up
      BeerDb::CreateDbExtrasNotes.new.up
      BeerDb::CreateDbExtrasDrinks.new.up
    else
      LogDb.create
      ConfDb.create
      TagDb.create
      WorldDb.create
      BeerDb.create
    end
    puts 'Done.'
  end # action
end # command create


desc "Create DB schema 'n' load all world and beer data"
arg_name 'NAME'   # optional setup profile name
command [:setup,:s] do |c|

  c.desc 'Beer data path'
  c.arg_name 'PATH'
  c.default_value opts.data_path
  c.flag [:i,:include]

  c.desc 'World data path'
  c.arg_name 'PATH'
  c.flag [:worldinclude]   ## todo: use --world-include - how? find better name? add :'world-include' ???

  c.action do |g,o,args|

    connect_to_db( opts )
 
    ## todo: document optional setup profile arg (defaults to all)
    setup = args[0] || 'all'
    
    LogDb.create
    ConfDb.create
    TagDb.create
    WorldDb.create
    BeerDb.create

    WorldDb.read_all( opts.world_data_path )
    BeerDb.read_setup( "setups/#{setup}", opts.data_path )
    puts 'Done.'
  end # action
end  # command setup


desc 'Update all beer data'
arg_name 'NAME'   # optional setup profile name
command [:update,:up,:u] do |c|

  c.desc 'Beer data path'
  c.arg_name 'PATH'
  c.default_value opts.data_path
  c.flag [:i,:include]

  c.desc 'Delete all beer data records'
  c.switch [:delete], negatable: false 

  c.action do |g,o,args|

    connect_to_db( opts )

    ## todo: document optional setup profile arg (defaults to all)
    setup = args[0] || 'all'

    BeerDb.delete! if o[:delete].present?

    BeerDb.read_setup( "setups/#{setup}", opts.data_path )
    puts 'Done.'
  end # action
end  # command setup



desc 'Load beer fixtures'
arg_name 'NAME'   # multiple fixture names - todo/fix: use multiple option
command [:load, :l] do |c|

  c.desc 'Delete all beer data records'
  c.switch [:delete], negatable: false 

  c.action do |g,o,args|

    connect_to_db( opts )
    
    BeerDb.delete! if o[:delete].present?

    reader = BeerDb::Reader.new( opts.data_path )

    args.each do |arg|
      name = arg     # File.basename( arg, '.*' )
      reader.load( name )
    end # each arg

    puts 'Done.'
  end
end # command load



## fix/todo: add server alias (serve/server)

desc 'Start web service (HTTP JSON API)'
command [:serve,:server] do |c|

  c.action do |g,o,args|

    connect_to_db( opts )

    # NB: server (HTTP service) not included in standard default require
    require 'beerdb/service'

# make sure connections get closed after every request e.g.
#
#  after do
#   ActiveRecord::Base.connection.close
#  end
#

    puts 'before add middleware ConnectionManagement'
    BeerDb::Service.use ActiveRecord::ConnectionAdapters::ConnectionManagement
    puts 'after add middleware ConnectionManagement'
    ## todo: check if we can check on/dump middleware stack

    ## rack middleware might not work with multi-threaded thin web server; close it ourselfs
    BeerDb::Service.after do
      puts "  #{Thread.current.object_id} -- make sure db connections gets closed after request"
      # todo: check if connection is open - how? 
      ActiveRecord::Base.connection.close
    end    

    BeerDb::Service.run!

    puts 'Done.'
  end
end # command serve


desc 'Show stats'
command :stats do |c|
  c.action do |g,o,args|

    connect_to_db( opts ) 
    
    BeerDb.tables
    
    puts 'Done.'
  end
end


desc 'Show props'
command :props do |c|
  c.action do |g,o,args|

    connect_to_db( opts )
    
    ### fix: use ConfDb.props or similar !!!
    ### BeerDb.props
    
    puts 'Done.'
  end
end


desc 'Show logs'
command :logs do |c|
  c.action do |g,o,args|

    connect_to_db( opts ) 
    
    LogDb::Models::Log.all.each do |log|
      puts "[#{log.level}] -- #{log.msg}"
    end
    
    puts 'Done.'
  end
end



desc '(Debug) Test command suite'
command :test do |c|
  c.action do |g,o,args|

    puts "hello from test command"
    puts "args (#{args.class.name}):"
    pp args
    puts "o (#{o.class.name}):"
    pp o
    puts "g (#{g.class.name}):"
    pp g
    
    LogUtils::Logger.root.debug 'test debug msg'
    LogUtils::Logger.root.info 'test info msg'
    LogUtils::Logger.root.warn 'test warn msg'
    
    puts 'Done.'
  end
end



pre do |g,c,o,args|
  opts.merge_gli_options!( g )
  opts.merge_gli_options!( o )

  puts BeerDb.banner

  if opts.verbose?
    LogUtils::Logger.root.level = :debug
  end

  logger.debug "Executing #{c.name}"   
  true
end

post do |global,c,o,args|
  logger.debug "Executed #{c.name}"
  true
end


on_error do |e|
  puts
  puts "*** error: #{e.message}"

  if opts.verbose?
    puts e.backtrace
  end

  false # skip default error handling
end


exit run(ARGV)