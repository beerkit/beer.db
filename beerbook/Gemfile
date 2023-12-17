source 'https://rubygems.org'

gem 'rails', '3.2.12'

gem 'sinatra', require: 'sinatra/base'


gem 'bourbon', '1.4.0' # scss mixins (see http://thoughtbot.com/bourbon)

gem 'logutils'
gem 'worlddb', '1.8.2'
gem 'beerdb',  '0.9.2'


#########################3
# data

gem 'worlddb-data', '99', :git => 'https://github.com/openmundi/world.db.git'

gem 'beerdb-data-world', '99', :git => 'https://github.com/openbeer/world.git'
gem 'beerdb-data-de',    '99', :git => 'https://github.com/openbeer/de-deutschland.git'
gem 'beerdb-data-at',    '99', :git => 'https://github.com/openbeer/at-austria.git'
gem 'beerdb-data-ch',    '99', :git => 'https://github.com/openbeer/ch-confoederatio-helvetica.git'
gem 'beerdb-data-cz',    '99', :git => 'https://github.com/openbeer/cz-czech-republic.git'
gem 'beerdb-data-be',    '99', :git => 'https://github.com/openbeer/be-belgium.git'
gem 'beerdb-data-nl',    '99', :git => 'https://github.com/openbeer/nl-netherlands.git'
gem 'beerdb-data-ie',    '99', :git => 'https://github.com/openbeer/ie-ireland.git'
gem 'beerdb-data-ca',    '99', :git => 'https://github.com/openbeer/ca-canada.git'
gem 'beerdb-data-us',    '99', :git => 'https://github.com/openbeer/us-united-states.git'
gem 'beerdb-data-mx',    '99', :git => 'https://github.com/openbeer/mx-mexico.git'
gem 'beerdb-data-jp',    '99', :git => 'https://github.com/openbeer/jp-japan.git'


##################################
# logos

gem 'worlddb-flags', '0.1.0'   # use bundled country flags




########
# add engines

gem 'beerdb-admin'     # , '0.0.1', path: './engine'


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
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
