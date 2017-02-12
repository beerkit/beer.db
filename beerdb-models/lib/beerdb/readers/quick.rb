# encoding: utf-8

#####################################
#  quick (all-in-one-file) reader
#
#  reads breweries n beers "mixed-up" in a single-file


module BeerDb

class QuickReader

  include LogUtils::Logging

## make models available by default with namespace
#  e.g. lets you use Usage instead of Model::Usage
  include Models

  def self.from_zip( zip_file, entry_path, more_attribs={} )
    ## get text content from zip
    entry = zip_file.find_entry( entry_path )

    text = entry.get_input_stream().read()
    text = text.force_encoding( Encoding::UTF_8 )

    self.from_string( text, more_attribs )
  end

  def self.from_file( path, more_attribs={} )
    ## note: assume/enfore utf-8 encoding (with or without BOM - byte order mark)
    ## - see textutils/utils.rb
    text = File.read_utf8( path )
    self.from_string( text, more_attribs )
  end

  def self.from_string( text, more_attribs={} )
    QuickReader.new( text, more_attribs )
  end  

  def initialize( text, more_attribs={} )
    ## todo/fix: how to add opts={} ???
    @text = text
    @more_attribs = more_attribs
  end


  def read()

    ########
    # note:
    #   assume meta.format == multiline  => brewery
    #                      == line       => beer

    last_brewery = nil

    reader = ValuesReader.from_string( @text, @more_attribs )

    reader.each_line_with_meta do |attributes|

      ## note: group header not used for now; do NOT forget to remove from hash!
      if attributes[:header].present?
        logger.warn "removing unused group header #{attributes[:header]}"
        attributes.delete(:header)   ## note: do NOT forget to remove from hash!
      end

      if attributes[:meta][:format] == :multiline
        ### assume new brewery
        puts
        puts "new brewery w/ attributes: #{attributes.inspect}"
      else
        ### assume new beer
        puts
        puts "new beer w/ attributes: #{attributes.inspect}"
      end

      meta   = attributes[:meta]
      values = attributes[:values]

      attributes.delete(:meta)
      attributes.delete(:values)

      if meta[:format] == :multiline
        ## assume new brewery
        ### check values for worldtree entry w/ › e.g. Hainaut › Belgium

        worldtree = values.find {|val| val.index('›') }
        if worldtree
          puts "  worldtree: #{worldtree}"
          worldtree_ary = worldtree.split( /\s*›\s*/ )   ## note: remove leading n trailing spaces
          pp worldtree_ary
          ## assume last entry is country
          country_name = worldtree_ary[-1]
          puts "     country: #{country_name}"

          country = Country.find_by_name( country_name )
          if country.nil?
            puts "  auto-add country #{country_name}"
            ## hack: fix use worldlite to get proper key,code,area,pop etc.
            country = Country.create!( key:  country_name[0..2].downcase,
                                       name: country_name,
                                       code: country_name[0..2].upcase,
                                       area: 0,
                                       pop:  0 )
          end

          attributes[:country_id] = country.id

          last_brewery = Brewery.create_or_update_from_attribs( attributes, values )
        else
          puts "  worldtree missing (no country etc.) !!!!!"
          exit
        end
      else
        ## assume new beer
        attributes[:brewery_id] = last_brewery.id
        attributes[:country_id] = last_brewery.country_id

        Beer.create_or_update_from_attribs( attributes, values )
      end

    end # each_line
  end


end # class QuickReader
end # module BeerDb

