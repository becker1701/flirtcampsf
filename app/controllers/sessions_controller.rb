class SessionsController < ApplicationController
  def new
  end

  def create
    # debugger

  	@user = User.find_by(email: params[:email].downcase) if params[:email].present?
  	if @user && @user.authenticate(params[:password])
      if @user.activated?
    		flash[:success] = "Wecome back!"
        params[:remember_me] == '1' ? remember(@user) : forget(@user)
        log_in @user
    		redirect_back_or user_url(@user)
      else
        flash[:warning] = "Account not activated. Please check your email for the activation link."
        redirect_to root_url
      end
  	else
      
  		flash.now[:danger] = "We could not find a user with that email/password combination."
  		render :new
  	end
  end

  def destroy
    logout
    redirect_to root_url
  end

private

end
