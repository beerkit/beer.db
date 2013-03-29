# encoding: utf-8

require 'commander/import'

require 'logutils/db'   # add support for logging to db
require 'beerdb/cli/opts'

LogUtils::Logger.root.level = :info   # set logging level to info 


program :name,  'beerdb'
program :version, BeerDb::VERSION
program :description, "beer.db command line tool, version #{BeerDb::VERSION}"


# default_command :help
default_command :load

program :help_formatter, Commander::HelpFormatter::TerminalCompact


## todo: find a better name e.g. change to settings? config? safe_opts? why? why not?
myopts = BeerDb::Opts.new

### global option (required)
## todo: add check that path is valid?? possible?

global_option '-i', '--include PATH', String, "Data path (default is #{myopts.data_path})"
global_option '-d', '--dbpath PATH', String, "Database path (default is #{myopts.db_path})"
global_option '-n', '--dbname NAME', String, "Database name (datault is #{myopts.db_name})"

global_option '-q', '--quiet', "Only show warnings, errors and fatal messages"
### todo/fix: just want --debug/--verbose flag (no single letter option wanted) - fix
global_option '-w', '--verbose', "Show debug messages"


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


command :create do |c|
  c.syntax = 'beerdb create [options]'
  c.description = 'Create DB schema'
  c.action do |args, options|

    LogUtils::Logger.root.level = :warn    if options.quiet.present?
    LogUtils::Logger.root.level = :debug   if options.verbose.present?

    myopts.merge_commander_options!( options.__hash__ )
    connect_to_db( myopts )
    
    LogDb.create
    WorldDb.create
    BeerDb.create
    puts 'Done.'
  end # action
end # command create

command :setup do |c|
  c.syntax = 'beerdb setup [options]'
  c.description = "Create DB schema 'n' load all data"

  c.option '--world', 'Populate world tables'
  ## todo: use --world-include - how? find better name?
  c.option '--worldinclude PATH', String, 'World data path'

  c.option '--beer', 'Populate beer tables'
  c.option '--delete', 'Delete all records'

  c.action do |args, options|

    LogUtils::Logger.root.level = :warn    if options.quiet.present?
    LogUtils::Logger.root.level = :debug   if options.verbose.present?

    myopts.merge_commander_options!( options.__hash__ )
    connect_to_db( myopts )

    ## todo: document optional setup profile arg (defaults to all)
    setup = args[0] || 'all'
    
    if options.world.present? || options.beer.present?
      
      ## todo: check order for reference integrity
      #  not really possible to delete world data if sport data is present
      #   delete sport first
      
      if options.delete.present?
        BeerDb.delete! if options.beer.present?
        WorldDb.delete! if options.world.present?
      end
      
      if options.world.present?
        WorldDb.read_all( myopts.world_data_path )
      end
      
      if options.beer.present?
        BeerDb.read_setup( "setups/#{setup}", myopts.data_path )
      end

    else  # assume "plain" regular setup
      LogDb.create
      WorldDb.create
      BeerDb.create
    
      WorldDb.read_all( myopts.world_data_path )
      BeerDb.read_setup( "setups/#{setup}", myopts.data_path )
    end

    puts 'Done.'
  end # action
end  # command setup

command :load do |c|
  ## todo: how to specify many fixutes <>... ??? in syntax
  c.syntax = 'beerdb load [options] <fixtures>'
  c.description = 'Load fixtures'

  c.option '--delete', 'Delete all records'

  c.action do |args, options|

    LogUtils::Logger.root.level = :warn    if options.quiet.present?
    LogUtils::Logger.root.level = :debug   if options.verbose.present?

    myopts.merge_commander_options!( options.__hash__ )
    connect_to_db( myopts )
    
    if options.delete.present?
      LogDb.delete!
      BeerDb.delete!
    end

    # read plain text country/region/city fixtures
    reader = BeerDb::Reader.new( myopts.data_path )
    args.each do |arg|
      name = arg     # File.basename( arg, '.*' )
      reader.load( name )
    end # each arg
    
    puts 'Done.'
  end
end # command load


command :stats do |c|
  c.syntax = 'beerdb stats [options]'
  c.description = 'Show stats'
  c.action do |args, options|

    LogUtils::Logger.root.level = :warn    if options.quiet.present?
    LogUtils::Logger.root.level = :debug   if options.verbose.present?

    myopts.merge_commander_options!( options.__hash__ )
    connect_to_db( myopts ) 
    
    BeerDb.tables
    
    puts 'Done.'
  end
end


command :props do |c|
  c.syntax = 'beerdb props [options]'
  c.description = 'Show props'
  c.action do |args, options|

    LogUtils::Logger.root.level = :warn    if options.quiet.present?
    LogUtils::Logger.root.level = :debug   if options.verbose.present?

    myopts.merge_commander_options!( options.__hash__ )
    connect_to_db( myopts ) 
    
    BeerDb.props
    
    puts 'Done.'
  end
end


command :logs do |c|
  c.syntax = 'beerdb logs [options]'
  c.description = 'Show logs'
  c.action do |args, options|

    LogUtils::Logger.root.level = :warn    if options.quiet.present?
    LogUtils::Logger.root.level = :debug   if options.verbose.present?

    myopts.merge_commander_options!( options.__hash__ )
    connect_to_db( myopts ) 
    
    LogDb::Models::Log.all.each do |log|
      puts "[#{log.level}] -- #{log.msg}"
    end
    
    puts 'Done.'
  end
end



command :test do |c|
  c.syntax = 'beerdb test [options]'
  c.description = 'Debug/test command suite'
  c.action do |args, options|
    puts "hello from test command"
    puts "args (#{args.class.name}):"
    pp args
    puts "options:"
    pp options
    puts "options.__hash__:"
    pp options.__hash__
    puts 'Done.'
  end
end
