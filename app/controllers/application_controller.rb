class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_user
    if session[:user_id] == nil
      session[:user_id] = rand(36**8).to_s(36)
    else
      session[:user_id]
    end
  end
end
