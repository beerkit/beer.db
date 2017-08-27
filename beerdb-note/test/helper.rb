
## $:.unshift(File.dirname(__FILE__))

## minitest setup

require 'minitest/autorun'


# our own code
require 'beerdb/note'

### setup_in_memory_db

ActiveRecord::Base.logger = Logger.new( STDOUT )

ActiveRecord::Base.establish_connection( adapter:  'sqlite3',
                                         database: ':memory:' )
