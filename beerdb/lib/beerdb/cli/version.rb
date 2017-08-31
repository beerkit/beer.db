# encoding: utf-8

# Note: BeerDb::VERSION gets used by core, that is, beerdb-models


module BeerDbTool    # todo/check - rename to BeerDbCli or BeerDbCommands or BeerDbShell ??

  MAJOR = 1
  MINOR = 2
  PATCH = 2
  VERSION = [MAJOR,MINOR,PATCH].join('.')

  def self.version
    VERSION
  end

  def self.banner
    "beerdb/#{VERSION} on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
  end

  def self.root
    "#{File.expand_path( File.dirname(File.dirname(File.dirname(File.dirname(__FILE__)))) )}"
  end

end # module BeerDbTool
