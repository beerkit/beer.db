source 'https://rubygems.org'

gem 'rails', '3.2.12'

gem 'sinatra', require: 'sinatra/base'

gem 'fetcher' # for fetching/downloading zips

gem 'bourbon', '1.4.0' # scss mixins (see http://thoughtbot.com/bourbon)


gem 'logutils'
gem 'beerdb',  '0.9.13'
gem 'worlddb'


##################################
# logos

gem 'worlddb-flags', '0.1.0'   # use bundled country flags


########
# add engines

gem 'beerdb-admin', '0.0.1', path: './engine'

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
  gem 'hoe'   # NOTE: check - rake called via rvm? uses bundle? 
end


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
