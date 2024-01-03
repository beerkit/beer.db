
require 'hoe'
require './lib/beerdb/labels/version.rb'


Hoe.spec 'beerdb-labels' do

  self.version = BeerDb::Labels::VERSION

  self.summary = 'beerdb-labels gem - beer labels (24x24, 32x32, 48x48, 64x64) bundled for reuse w/ asset pipeline'
  self.description = summary

  self.urls    = ['https://github.com/beerdblabels/beer.db.labels.ruby']

  self.author  = 'Gerald Bauer'
  self.email   = 'beerdb@googlegroups.com'

  self.readme_file  = 'README.md'
  self.history_file = 'History.md'

end


################################
#


# ls *.jpg | xargs -r -I FILE convert FILE -thumbnail 64x64 FILE_thumb.png

LABEL_SIZES = [24,32,48,64]  # e.g. 24x24, 32x32, etc.

# NB: labels reside in its own repo! - clone as a sibling to this repo to make it work
LABEL_INPUT_DIR = '../beer.db.labels'

LABEL_OUTPUT_DIR = 'vendor/assets/images/labels'



require 'hybook'


desc 'debug build album'
task :debug_album do
  album = HyBook::Album.create_from_folder( LABEL_INPUT_DIR, title: 'beer.db.labels' )
  pp album

  puts HyBook.render_album( album,
                               size: 24,
                               assets_path: 'vendor/assets/images/labels' )
end


desc 'beerdb-labels - build album pages'
task :albums do

  PAGES_DIR = './site'

  album =  HyBook::Album.create_from_folder( LABEL_INPUT_DIR, title: 'beer.db.labels' ) 

  ## build one album page per logo size (e.g. 24x24, 32x32 etc.)
  LABEL_SIZES.each do |size|

    TextUtils::Page.create( "#{PAGES_DIR}/#{size}.md", frontmatter: {
                                                          layout: 'album',
                                                          title: "beer.db.labels (#{size}x#{size})",
                                                          permalink: "/#{size}.html" } ) do |page|
        page.write HyBook.render_album( album,
                                          title: "beer.db.labels (#{size}x#{size})",
                                          size: size,
                                          assets_path: 'vendor/assets/images/labels' )
    end # page
  end # each LABEL_SIZES

  puts 'Done.'
end





desc 'beerdb-labels - build thumbs'
task :build_thumbs  do

  files = Dir[ "#{LABEL_INPUT_DIR}/**/*.{png,gif,jpg}" ]

  files.each do |filename|
    extname  = File.extname( filename )
    basename = File.basename( filename, extname )   # NB: remove extname (that is, suffix e.g. .png,.jpg,.gif etc.)

    puts "filename: #{filename}, basename: #{basename}, extname: #{extname}"

    LABEL_SIZES.each do |size|
      
      ## make sure outputdir exits
      FileUtils.mkpath( "#{LABEL_OUTPUT_DIR}/#{size}x#{size}" )  unless File.exists?( "#{LABEL_OUTPUT_DIR}/#{size}x#{size}" )

      # e.g. convert #{filename} -thumbnail 48x48 vendor/assets/images/labels/48x48/#{basename}.png"
      cmd = "convert #{filename} -thumbnail #{size}x#{size} #{LABEL_OUTPUT_DIR}/#{size}x#{size}/#{basename}.png"
      puts "  #{cmd}"
      system( cmd )
    end
  end
  
  ## todo: generate lookup list of all available labels (lets us check if label exists)
  puts 'Done.'
end


desc 'beerdb-labels - build manifest'
task :build_manifest  do

  txt = File.read( 'Manifest.txt.tpl' )

  ## append all thumbnails (24x24,32x32,48x48,64x64)

  files = Dir[ "#{LABEL_INPUT_DIR}/**/*.{png,gif,jpg}" ]
  files = files.map do |filename|
    # strip folders
    # force extension  to .png

    extname  = File.extname( filename )
    basename = File.basename( filename, extname )   # NB: remove extname (that is, suffix e.g. .png,.jpg,.gif etc.)

    puts "filename: #{filename}, basename: #{basename}, extname: #{extname}"
    "#{basename}.png"
  end
  files.sort!


  LABEL_SIZES.each do |size|
    files.each do |filename|
       txt << "#{LABEL_OUTPUT_DIR}/#{size}x#{size}/#{filename}\n"
    end
  end

  File.open( 'Manifest.txt', 'w') do |file|
    file.write( txt )
  end

  puts 'Done.'
end


desc 'beerdb-labels - build thumbnails from originals'
task :build => [:build_thumbs, :build_manifest]
