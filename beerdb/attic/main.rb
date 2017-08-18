
## setup command no longer supported
##   - use a datafile to get started

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

    BeerDb.create_all

    WorldDb.read_all( opts.world_data_path )
    BeerDb.read_setup( "setups/#{setup}", opts.data_path )
    puts 'Done.'
  end # action
end  # command setup


## old server / service commands

## fix/todo: add server alias (serve/server)

desc 'Start web service (HTTP JSON API)'
command [:serve,:server] do |c|

  c.action do |g,o,args|

    connect_to_db( opts )

    # Note: server (HTTP service) not included in standard default require
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
