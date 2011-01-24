class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
 
  before_filter :maintain_session_and_user
  before_filter :ensure_login, :except => [:session, :destroy] 
 
  protect_from_forgery
  
  def ensure_login
    unless @app_user
      flash[:notice] = "Please login to continue"
      redirect_to(new_session_path)
    end
  end
  
  def ensure_logout
    if @app_user
      flash[:notice] = "You must logout before you can login or register"
      redirect_to(root_url)
    end
  end
  
  private
  
  def maintain_session_and_user
    if session[:id]
      if @app_session = Session.find_by_id(session[:id])
        @app_session.update_attributes(
          :ip_address => request.remote_addr,
          :path => request.path_info
        )
        @app_user = @app_session.user
        @app_user.increment!(:requests)
      else
        session[:id] = nil
        redirect_to(root_url)
      end
    end
  end
end