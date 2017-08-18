
## world_data_path no longer a supported option
##   - use a datfile instead

@world_data_path = options[:worldinclude] if options[:worldinclude].present?

def world_data_path
  @world_data_path   # Note: option has no default; return nil
end
