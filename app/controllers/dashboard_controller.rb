# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  def show
    if Current.shop
      @products = Current.shop.products
      @today_sales = Current.shop.sales.where(created_at: Time.current.all_day)
      @total_sales = @today_sales.sum(:total_cents).to_f / 100.0
      @low_stock_count = Current.shop.products.where("current_stock <= reorder_level").count
      @recent_sales = Current.shop.sales.includes(:customer).order(created_at: :desc).limit(5)
    else
      redirect_to login_path, alert: "No shop associated with your account."
    end
  end
end