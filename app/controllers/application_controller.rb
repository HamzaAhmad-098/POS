# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :set_current_user
  before_action :set_current_shop
  before_action :authenticate_user!
  
  private
  
  def set_current_user
    Current.user = current_user
  end
  
  def set_current_shop
    if current_user && current_user.shop
      Current.shop = current_user.shop
    end
  end
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  
  def authenticate_user!
    unless current_user
      redirect_to login_path, alert: "Please log in first."
    end
  end
  
  def require_owner
    unless current_user&.role_owner? || current_user&.role_admin?
      redirect_to dashboard_path, alert: "Access denied."
    end
  end
  
  def require_admin
    unless current_user&.role_admin?
      redirect_to dashboard_path, alert: "Admin access required."
    end
  end
  
  helper_method :current_user
end