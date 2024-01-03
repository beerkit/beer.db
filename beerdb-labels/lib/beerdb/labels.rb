
require 'beerdb/labels/version'

module BeerDb::Labels

  def self.banner
    "beerdb-labels #{VERSION} on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
  end

end  # module BeerDb::Labels

require 'beerdb/labels/engine'

## say hello
puts BeerDb::Labels.banner
