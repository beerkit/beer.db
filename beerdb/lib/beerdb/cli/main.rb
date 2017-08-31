# encoding: utf-8

### Note: wrap gli config into a class
##  see github.com/davetron5000/gli/issues/153


module BeerDb

  class Tool
     def initialize
       LogUtils::Logger.root.level = :info   # set logging level to info
     end

     def run( args )
       puts BeerDbTool.banner
       Toolii.run( args )
     end
  end


  class Toolii
    extend GLI::App

   def self.logger=(value) @@logger=value; end
   def self.logger()       @@logger; end

   ## todo: find a better name e.g. change to settings? config? safe_opts? why? why not?
   def self.opts=(value)  @@opts = value; end
   def self.opts()        @@opts; end


   def self.connect_to_db( options )
     puts "working directory: #{Dir.pwd}"

     BeerDb.connect( adapter: 'sqlite3',
                     database: "#{options.db_path}/#{options.db_name}" )

     LogDb.setup  # start logging to db (that is, save logs in logs table in db)
   end



logger = LogUtils::Logger.root
opts   = BeerDb::Opts.new



program_desc 'beer.db command line tool'
version BeerDbTool::VERSION


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



desc "Build DB (download/create/read); use ./Datafile - zips get downloaded to ./tmp"
command [:build,:b] do |c|

  c.action do |g,o,args|

    datafile = Datafile::Datafile.load_file( './Datafile' )
    datafile.download  # datafile step 1 - download all datasets/zips

    connect_to_db( opts )

    BeerDb.create_all

    datafile.read  # datafile step 2 - read all datasets

    puts 'Done.'
  end # action
end  # command setup


desc "Read datasets; use ./Datafile - zips required in ./tmp"
command [:read,:r] do |c|

  c.action do |g,o,args|

    connect_to_db( opts )

    datafile = Datafile::Datafile.load_file( './Datafile' )
    datafile.read

    puts 'Done.'
  end # action
end  # command setup


desc "Download datasets; use ./Datafile - zips get downloaded to ./tmp"
command [:download,:dl] do |c|

  c.action do |g,o,args|

    # note: no database connection needed (check - needed for logs?? - not setup by default???)

    datafile = Datafile::Datafile.load_file( './Datafile' )
    datafile.download

    puts 'Done.'
  end # action
end  # command setup


desc "Build DB w/ quick starter Datafile templates"
arg_name 'NAME'   # optional setup profile name
command [:new,:n] do |c|

  c.action do |g,o,args|

    ## todo: required template name (defaults to at)
    setup = args[0] || 'at'

    worker = Fetcher::Worker.new
    ## note: lets use http:// instead of https:// for now - lets us use person proxy (NOT working w/ https for now)
    worker.copy( "http://github.com/openbeer/datafile/raw/master/#{setup}.rb", './Datafile' )

    ## step 2: same as command build (todo - reuse code)
    datafile = Datafile::Datafile.load_file( './Datafile' )
    datafile.download  # datafile step 1 - download all datasets/zips

    connect_to_db( opts )  ### todo: check let connect go first?? - for logging (logs) to db  ???

    BeerDb.create_all

    datafile.read  # datafile step 2 - read all datasets

    puts 'Done.'
  end # action
end  # command setup



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
      BeerDb.create_all
    end
    puts 'Done.'
  end # action
end # command create




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

    ## fix: use ConfDb.dump or similar
    ConfDb::Models::Prop.all.each do |prop|
      puts "#{prop.key}  |  #{prop.value}"
    end

    puts 'Done.'
  end
end


desc 'Show logs'
command :logs do |c|
  c.action do |g,o,args|

    connect_to_db( opts )

    ## fix: use LogDb.dump or similar
    LogDb::Models::Log.all.each do |log|
      puts "[#{log.level}] -- #{log.msg}"
    end

    puts 'Done.'
  end
end



desc 'Start web service (HTTP JSON API)'
arg_name 'NAME'   # optional setup profile name
command [:serve,:server,:s] do |c|

  c.action do |g,o,args|

    ## todo: document optional script arg (defaults to service)
    script = args[0] || 'service'

    ## todo/fix: add support for (default) Service (with no extension)

    script_path = "#{script}.rb"     ## auto-add .rb extension

    unless File.exist?( script_path ) ## if file doesn't exist try to fetch service script
      script_path = "./#{script}.rb"   ## use / save script in local (current) working dir/folder
      worker = Fetcher::Worker.new
      ## note: lets use http:// instead of https:// for now - lets us use person proxy (NOT working w/ https for now)
      worker.copy( "http://github.com/beerkit/beer.db.service/raw/master/#{script}.rb", script_path )
    end


    code = File.read_utf8( script_path )

    connect_to_db( opts )

    BeerDb.tables   ## print table stats

    BeerDbService.class_eval( code )  ## note: MUST use class_eval (do NOT use instance_eval)  !!!

    puts "dump routes:"
    pp BeerDbService.routes

    puts "starting server..."
    BeerDbService.run!

    puts 'Done.'
  end
end # command serve



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


### exit run(ARGV)  ## note: use Toolii.run( ARGV ) outside of class

  end  # class Toolii
end  # module BeerDb
