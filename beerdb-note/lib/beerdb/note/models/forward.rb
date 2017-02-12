# encoding: UTF-8


### forward references
##   require first to resolve circular references

module BeerDb
  module Model

  class User < ActiveRecord::Base ; end
  class Bookmark < ActiveRecord::Base ; end
  class Drink < ActiveRecord::Base ; end
  class Note < ActiveRecord::Base ; end

  end # module Model
end # module BeerDb

