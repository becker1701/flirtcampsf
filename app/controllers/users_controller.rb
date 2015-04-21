class UsersController < ApplicationController

  before_action :get_user, only: [:show, :edit, :update, :destroy]
  before_action :get_invite, only: [:new, :create]
  # before_action :invited, only: [:new, :create]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  before_action :next_event, only: [:index, :show]

  def index  
    @users = User.activated.paginate(page: params[:page])
  end


  def new
    
    # debugger
    if @invite
      @user = User.new(name: @invite.name, email: @invite.email)
    else
      @user = User.new
    end
  end

  def create
    # debugger
  	@user = User.new(user_params)
  	if @user.save
      
      if params[:invite].present? && @invite.email == @user.email
        @user.activate!
        log_in @user
        flash[:info] = "Welcome!"
      else
        flash[:info] = "Check your email to activate your profile"
        @user.send_activation_email
      end

  		
  		redirect_to root_url
  	else
  		render :new
  	end
  end

  def show
  	@user = User.find(params[:id])
    # debugger
  end

  def edit
  end

  def update
    # 
    if @user.update_attributes(user_params)
      flash[:success] = "Your profile has been updated!"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = "User deleted."
    else
      @user.errors.full_messages.each do |msg|
        flash[:danger] = msg
      end
    end
    redirect_to users_url
  end

private

	def get_user
		@user = User.find(params[:id])
	end

	def user_params
		params.require(:user).permit(:name, :email, :password, :password_confirmation, :playa_name, :phone, :invitation, :hometown)
	end



  def correct_user
    redirect_to root_url unless current_user?(@user)
  end

  def get_invite
    @invite = Invitation.find_by(id: params[:invite]) if params[:invite]
  end

  def invited
    redirect_to root_url unless @invite
  end
end
