module SetCurrentShop
  extend ActiveSupport::Concern

  included do
    before_action :set_current_shop
  end

  def set_current_shop
    # Set Current.user earlier (based on session or token)
    # For example, if user is logged in:
    if current_user && current_user.shop.present?
      Current.shop = current_user.shop
    elsif params[:shop_id].present?
      Current.shop = Shop.find_by(id: params[:shop_id])
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
end
