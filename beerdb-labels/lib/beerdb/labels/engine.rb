
module BeerDb::Labels
  
  class Engine < Rails::Engine
    # NB: get rails to add app/assets, lib/assets and vendor/assets
    #        to the search path of Sprockets (asset pipeline)
    #
    # see Gemify Assets for Rails
    #  - http://prioritized.net/blog/gemify-assets-for-rails
    # or
    #  Adding Assets to Your Gems (Asset Pipeline Guide)
    #  - http://guides.rubyonrails.org/asset_pipeline.html#adding-assets-to-your-gems
  end
  
end # module BeerDb::Labels
