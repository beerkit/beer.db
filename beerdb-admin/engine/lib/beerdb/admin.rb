
require 'beerdb/admin/version'
require 'beerdb/admin/engine'

module BeerDbAdmin

  def self.banner
    "beerdb-admin/#{VERSION} on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
  end

  ##  cut off folders lib(#1)/sportdb(#2) to get to root
  def self.root
    "#{File.expand_path( File.dirname(File.dirname(File.dirname(__FILE__))) )}"
  end

end


puts BeerDbAdmin.banner    # say hello

