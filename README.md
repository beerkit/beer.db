# beerdb

beer.db Command Line Tool in Ruby

* home  :: [github.com/beerkit/beer.db.ruby](https://github.com/beerkit/beer.db.ruby)
* bugs  :: [github.com/beerkit/beer.db.ruby/issues](https://github.com/beerkit/beer.db.ruby/issues)
* gem   :: [rubygems.org/gems/beerdb](https://rubygems.org/gems/beerdb)
* rdoc  :: [rubydoc.info/gems/beerdb](http://rubydoc.info/gems/beerdb)
* forum :: [groups.google.com/group/beerdb](https://groups.google.com/group/beerdb)


## Usage Command Line

      beer.db command line tool, version 0.5.0
    
      Commands:
        create               Create DB schema
        help                 Display global or [command] help documentation.
        load                 Load fixtures
        logs                 Show logs
        props                Show props
        serve                Start web service (HTTP JSON API)
        setup                Create DB schema 'n' load all data
        stats                Show stats
        test                 Debug/test command suite
    
      Global Options:
        -i, --include PATH   Data path (default is .) 
        -d, --dbpath PATH    Database path (default is .) 
        -n, --dbname NAME    Database name (datault is beer.db) 
        -q, --quiet          Only show warnings, errors and fatal messages 
        -w, --verbose        Show debug messages 
        -h, --help           Display help documentation 
        -v, --version        Display version information 
        -t, --trace          Display backtrace when an error occurs 


## Usage Models

Brewery Model

```
by = Brewery.find_by_key( 'guinness' )

by.title
=> 'St. James's Gate Brewery / Guinness Brewery'

by.country.key
=> 'ie'

by.country.title
=> 'Ireland'

by.city.title
=> 'Dublin'

by.beers.first
=> 'Guinness', 4.2

...
```


Beer Model

```
b = Beer.find_by_key( 'guinness' )

b.title
=> 'Guinness'

b.abv
=> 4.2

b.tags
=> 'irish_dry_stout', 'dry_stout', 'stout'

b.brewery.title
=> 'St. James's Gate Brewery / Guinness Brewery'

...
```


Country Model

```
at = Country.find_by_key( 'at' )

at.beers
=> 'Weitra Helles', 'Hadmar', 'Zwettler Original', ...

at.breweries
=> 'Weitra Bräu Bierwerkstatt', 'Zwettler Brauerei', ...

...
```


City Model

```
wien = City.find_by_key( 'wien' )

wien.beers
=> 'Ottakringer Helles', 'Ottakringer (Gold Fassl) Zwickl', ...

wien.breweries
=> 'Ottakringer Brauerei'

...
```


## Install

Just install the gem:

    $ gem install beerdb


## Free Open Public Domain Datasets

- [`beer.db`](https://github.com/openbeer) - free open public domain beer n brewery data for use in any (programming) language



## License

The `beerdb` scripts are dedicated to the public domain.
Use it as you please with no restrictions whatsoever.

## Questions? Comments?

Send them along to the [Open Beer & Brewery Database Forum/Mailing List](http://groups.google.com/group/beerdb).
Thanks!

