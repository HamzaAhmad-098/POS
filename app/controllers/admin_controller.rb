# app/controllers/admin_controller.rb
class AdminController < ApplicationController
  before_action :require_admin
  
  def dashboard
    @shops = Shop.all.includes(:subscription_plan)
    @total_shops = @shops.count
    @active_shops = @shops.where(is_active: true).count
  end
end