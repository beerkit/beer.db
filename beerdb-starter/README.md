# beer.db.starter - Build Your Own HTTP JSON API

The beerdb web service starter sample lets you build your own HTTP JSON API
using the
[`beer.db`](https://github.com/openbeer).  Example:

```ruby
class StarterApp < Webservice::Base

#####################
# Models

include BeerDb::Models   # e.g. Beer, Brewery, Brand, etc.


##############################################
# Controllers / Routing / Request Handlers

# try special (reserved) keys for random beer first
get '/beer/(r|rnd|rand|random)' do
  Beer.rnd
end

get '/beer/:key' do
  Beer.find_by! key: params[ 'key' ]
end


# try special (reserved) keys for random brewery first
get '/brewery/(r|rnd|rand|random)' do
  Brewery.rnd
end

get '/brewery/:key' do
  Brewery.find_by! key: params[ 'key' ]
end

 ...
end # class StarterApp
```

(Source: [`app.rb`](app.rb))



## Getting Started

Step 1: Install all libraries (Ruby gems) using bundler. Type:

    $ bundle install

Step 2: Copy an SQLite database e.g. `beer.db` into your folder.

Step 3: Startup the web service (HTTP JSON API). Type:

    $ ruby ./server.rb

That's it. Open your web browser and try some services
running on your machine on port 9292 (e.g. `localhost:9292`).



## License

The `beer.db.starter` scripts are dedicated to the public domain.
Use it as you please with no restrictions whatsoever.


## Questions? Comments?

Send them along to the
[Open Beer & Brewery Database Forum/Mailing List](http://groups.google.com/group/beerdb).
Thanks!
