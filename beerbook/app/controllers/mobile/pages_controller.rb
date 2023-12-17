
class Mobile::PagesController < Mobile::BaseController

  def home  # use start?? NB: only action w/ layout (all other request will use ajax)

    ## NB: add autorefresh in view 1s
    # if logged in redirect to mobile_time_path
    # else (not logged in) redirecto to mobile_signin_path (mobile_new_session_path)
      
     render layout: 'mobile'
  end

end # class Mobile::PagesController
