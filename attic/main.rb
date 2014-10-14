

desc 'Load beer fixtures'
arg_name 'NAME'   # multiple fixture names - todo/fix: use multiple option
command [:load, :l] do |c|

  c.desc 'Delete all beer data records'
  c.switch [:delete], negatable: false 

  c.action do |g,o,args|

    connect_to_db( opts )
    
    BeerDb.delete! if o[:delete].present?

    reader = BeerDb::Reader.new( opts.data_path )

    args.each do |arg|
      name = arg     # File.basename( arg, '.*' )
      reader.load( name )
    end # each arg

    puts 'Done.'
  end
end # command load

