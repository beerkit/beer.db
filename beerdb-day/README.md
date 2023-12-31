# beer.db.day

beer.db web app -  beer of the day, brewery of the day, breweries a-z


## Live Demo - Real World Example

Try some live installations:

- Austrian beers n breweries running @ [`at365.herokuapp.com`](http://at365.herokuapp.com)
- Belgian beers n breweries running @ [`be365.herokuapp.com`](http://be365.herokuapp.com)



## Setup Notes

### Step 1: Create the "empty" database tables

    rake db:migrate     # step 0: create database tables


### Step 2: Load beer 'n' brewery datasets

Use the rake tasks in `lib/tasks/load_data.rake` to download and import
the `world.db` and `beer.db` datasets.

For example, to setup the Belgium (`be`) Edition use:

    rake dl_world    # step 1a: download openmundi/world.db zip archive to ./tmp
    rake dl_be       # step 1b: download openbeer/be-belgium zip archive to ./tmp
    rake load_world  # step 2a: import world.db dataset from zip archive
    rake load_be     # step 2a: import beer 'n' brewery datasets from zip archive

For Austria (`at`) use:

    rake dl_world    # step 1a: download openmundi/world.db zip archive to ./tmp
    rake dl_at       # step 1b: download openbeer/at-austria zip archive to ./tmp
    rake load_world  # step 2a: import world.db dataset from zip archive
    rake load_at     # step 2a: import beer 'n' brewery datasets from zip archive



## License

The `beer.db.day` scripts are dedicated to the public domain.
Use it as you please with no restrictions whatsoever.

## Questions? Comments?

Send them along to the [Open Beer & Brewery Database Forum/Mailing List](http://groups.google.com/group/beerdb).
Thanks!

