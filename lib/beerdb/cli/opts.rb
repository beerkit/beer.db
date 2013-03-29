module BeerDb

class Opts


  def merge_commander_options!( options = {} )
    @db_path   = options[:dbpath]  if options[:dbpath].present?
    @db_name   = options[:dbname]  if options[:dbname].present?

    @data_path = options[:include] if options[:include].present?
    
    @world_data_path = options[:worldinclude] if options[:worldinclude].present? 
  end



  def db_path
    @db_path || '.'
  end

  def db_name
    @db_name || 'beer.db'
  end


  def data_path=(value)
    @data_path = value
  end

  def data_path
    @data_path || '.'
  end

  def world_data_path
    @world_data_path   # NB: option has no default; return nil
  end

end # class Opts

end # module BeerDb
