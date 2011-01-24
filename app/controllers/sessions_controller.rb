class SessionsController < ApplicationController

  before_filter :ensure_login, :only => :destroy
  before_filter :ensure_logout, :only => [:new, :create]
 
  def index
    redirect_to(new_session_path)
  end
 
  def new
    @session = Session.new
  end
 
  def create
    @session = Session.new(params[:session])
    if @session.save
      session[:id] = @session.id
      flash[:notice] = "Hello #{@session.user.name}, you are now logged in"
      redirect_to(root_url)
    else
      
      if @session.errors.any?
        flash[:notice] = @session.errors.full_messages.join(';')
      end
      render(:action => 'new')
    end
  end
 
  def destroy
    Session.destroy(@app_session)
    session[:id] = @app_user = nil
    flash[:notice] = "You have signed out"
  end
end

