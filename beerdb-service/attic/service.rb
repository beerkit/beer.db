
  def self.banner
    "beerdb-service #{BeerDb::VERSION} on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}] on Sinatra/#{Sinatra::VERSION} (#{ENV['RACK_ENV']})"
  end

  PUBLIC_FOLDER = "#{BeerDbService.root}/lib/beerdb/service/public"
  VIEWS_FOLDER  = "#{BeerDbService.root}/lib/beerdb/service/views"

  puts "[debug] beerdb-service - setting public folder to: #{PUBLIC_FOLDER}"
  puts "[debug] beerdb-service - setting views folder to: #{VIEWS_FOLDER}"

  set :public_folder, PUBLIC_FOLDER   # set up the static dir (with images/js/css inside)
  set :views,         VIEWS_FOLDER    # set up the views dir

  set :static, true   # set up static file routing

  #####################
  # Models

  include Models

  ##################
  # Helpers
  #
  #  NB: helpers are just instance methods! no need in modular apps to use
  #   helpers do
  #    <code>
  #  end

  def path_prefix
    request.env['SCRIPT_NAME']
  end



    get '/' do
      erb :index
    end



# say hello
puts BeerDbService.banner
