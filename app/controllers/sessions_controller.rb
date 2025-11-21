# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :otp_login]
  
  def new
    # Redirect if already logged in
    redirect_to dashboard_path if current_user
  end

  def create
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      user.update(last_login_at: Time.current)
      redirect_to dashboard_path, notice: "Logged in successfully!"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    Current.user = nil
    Current.shop = nil
    redirect_to login_path, notice: "Logged out successfully!"
  end

  def otp_login
    flash[:alert] = "OTP login not implemented yet"
    redirect_to login_path
  end
end