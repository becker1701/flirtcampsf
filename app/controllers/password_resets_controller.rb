class PasswordResetsController < ApplicationController

  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :expired_token, only: [:edit, :udpate]
  
  def new
  end

  def create
  	
    # 
  	@user = User.find_by(email: params[:password_reset][:email].downcase) if params[:password_reset][:email]
  	
  	if @user && !@user.activated?
      # @user.send_activation_email
      flash[:warning] = "Your account is not activated. Check your email for the activation link."
      redirect_to root_url

    elsif @user && @user.activated?
    	@user.reset_digest_attributes(:password_reset)
  		flash[:success] = "A password reset email has been sent."
		  redirect_to login_url
    
    else
      flash.now[:danger] = "Email address not found."
		  render :new
  	end

  end


  def edit
  end


  def update
    # 
    if password_blank?
      # flash.now[:danger] = "Password can't be blank."

      @user.blank_password_reset_error
      render :edit
    elsif @user.update_attributes(user_params)  
      log_in @user
      flash[:success] = "Password successfully reset"
      redirect_to @user
    else
      render :edit
    end      
  end


private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
      flash[:danger] = "Password reset link invalid."
      redirect_to root_url
    end
  end

  def expired_token
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired."
      redirect_to root_url
    end
  end

  def password_blank?
    params[:user][:password].blank?
  end

end
