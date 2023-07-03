class ApplicationController < ActionController::Base
  helper_method :current_user, :user_logged_in? , :current_manager , :manager_logged_in? , :manager_has_hotel?

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def user_logged_in?
    !!current_user
  end

  def current_manager
    @current_manager ||= Manager.find(session[:manager_id]) if session[:manager_id]
  end

  def manager_logged_in?
    !!current_manager
  end

  def manager_has_hotel?
    if manager_logged_in?
      managerHotel = @current_manager.hotel
      return !!managerHotel
    end
    return false
  end
end
