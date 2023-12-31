source 'https://rubygems.org'

gem 'rails', '3.2.14'

gem 'sinatra', require: 'sinatra/base'


gem 'logutils'
gem 'worlddb'
gem 'beerdb', '0.9.13'

gem 'fetcher'   # for downloading zips etc.

gem 'bourbon', '1.4.0' # scss mixins (see http://thoughtbot.com/bourbon)

##################################
# logos

gem 'worlddb-flags', '0.1.0'   # use bundled country flags


########
# add engines

gem 'beerdb-admin'

##########
# add sinatra (mountable) app(let)s

gem 'about'      # mountable app - about - sys info pages
gem 'dbbrowser'  # mountable app



group :production do
  gem 'pg'
  gem 'thin'    # use faster multiplexed (w/ eventmachine) web server
end

group :development do
  gem 'sqlite3'
  gem 'annotate', '~> 2.4.1.beta'
end


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

