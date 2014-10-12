

  module CodeReaderContext
    #  make models available w/o namespace
    #  e.g. lets you use Beer instead of BeerDb::Models::Beer
    include BeerDb::Models    # check does it work w/ alias e.g. Models == Model
    ## <evaluated code here>
  end

  def self.load( name, include_path='.' )  # NB: pass in w/o .rb extension e.g use users etc.
    path = "#{include_path}/#{name}.rb"

    puts "*** loading seed data '#{name}' (#{path})..."

    ::CodeReader.new( path ).eval( CodeReaderContext )
    ## nb: will get evaluated in context of passed in module like
    ## module CodeReaderContext
    ##  <seed code here>
    ## end
  end

