class AccountActivationsController < ApplicationController

	def new #for resetting the account activation
	end

	def create
		#send email
		@user = User.find_by(email: params[:account_activation][:email])
		if @user && !@user.activated?
			#reset account activation token
			@user.reset_digest_attributes(:activation)
			flash[:info] = "Please check your email to activate your account."
			redirect_to root_url

		elsif @user && @user.activated?
			flash[:info] = "Your account has already been activated. Use the Forgot Password link to reset your password."
			redirect_to login_url
		else
			flash.now[:danger] = "An account has not been setup with that email address."
			render :new
		end
	end


	def edit
		
		# debugger
		
		user = User.find_by(email: params[:email])
		# 
		if user && !user.activated? && user.authenticated?(:activation, params[:id])
			user.activate!
			flash[:success] = "Your account has been activated"
			log_in user
			redirect_to root_url
		else
			flash[:danger] = "Invalid activation link."
			redirect_to root_url
		end
	end

end
