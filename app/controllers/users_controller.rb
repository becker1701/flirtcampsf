class UsersController < ApplicationController

  before_action :get_user, only: [:show, :edit, :update, :delete]

  def new
  	@user = User.new
  end

  def create
  	@user = User.new(user_params)
  	if @user.save
  		flash[:success] = "Welcome to the Sample App!"
  		redirect_to @user
  	else
  		render :new
  	end
  end

  def show
  	@user = User.find(params[:id])
  end

private

	def get_user
		@user = User.find(params[:id])
	end

	def user_params
		params.require(:user).permit(:name, :email, :password, :password_confirmation)
	end
end
