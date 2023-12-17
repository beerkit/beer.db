
class Mobile::BaseController < ApplicationController

  # NB: pages#home only action w/ layout (all other request will use ajax w/o layout false/none)
  layout false

end

