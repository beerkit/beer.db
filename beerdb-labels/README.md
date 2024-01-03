# beer.db.labels

beerdb-labels gem - beer labels (24x24, 32x32, 48x48, 64x64) bundled for reuse w/ asset pipeline

* home  :: [github.com/beerlabels/beer.db.labels.ruby](https://github.com/beerlabels/beer.db.labels.ruby)
* bugs  :: [github.com/beerlabels/beer.db.labels.ruby/issues](https://github.com/beerlabels/beer.db.labels.ruby/issues)
* gem   :: [rubygems.org/gems/beerdb-labels](https://rubygems.org/gems/beerdb-labels)
* forum :: [groups.google.com/group/beerdb](https://groups.google.com/group/beerdb)

## Usage

### Rails Asset Pipline


In Your Gemfile add:

    gem 'beerdb-labels', '9.9.9',  :git => 'https://github.com/beerlabels/beer.db.labels.ruby.git' 

And use it like:

    image_tag( "labels/32x32/#{beer.key}.png" )   e.g.
    image_tag( 'labels/32x32/murphysred.png' )



## Album Pages / Label Previews

- [24x24](http://beerlabels.github.io/beer.db.labels.ruby/24.html)
- [32x32](http://beerlabels.github.io/beer.db.labels.ruby/32.html)
- [48x48](http://beerlabels.github.io/beer.db.labels.ruby/48.html)
- [64x64](http://beerlabels.github.io/beer.db.labels.ruby/64.html)



## Questions? Comments?

Send them along to the [Open Beer & Brewery Database Forum/Mailing List](http://groups.google.com/group/beerdb).
Thanks!

