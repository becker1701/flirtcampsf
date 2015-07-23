class UsersController < ApplicationController

  before_action :get_user, only: [:show, :edit, :update, :destroy, :camp_dues_notification]
  
  
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :camp_dues_notification]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy, :camp_dues_notification]
  
  before_action :get_invite, only: [:new, :create]
  # before_action :invited, only: [:new, :create]
  before_action :next_event, only: [:index, :show, :camp_dues_notification]
  


  def index  
      
      # binding.pry
    if params[:q].present?

      if params[:q] == "attending_next_event"
        @subtitle = "Members attending #{@next_event.year}"
        @users = User.activated.attending_next_event.paginate(page: params[:page])
        
      elsif params[:q] == "not_attending_next_event"
        @subtitle = "Members not attending #{@next_event.year}"
        @users = User.activated.not_attending_next_event.paginate(page: params[:page])
        
      elsif params[:q] == "not_responded_to_next_event"
        @subtitle = "Members not responded to #{@next_event.year}"
        @users = User.activated.not_responded_to_next_event.paginate(page: params[:page])
        
      elsif params[:q] == "has_ticket_to_next_event"
        @subtitle = "Members who have tickets to #{@next_event.year}"
        @users = User.activated.has_ticket_to_next_event.paginate(page: params[:page])

      elsif params[:q] == "needs_ticket_to_next_event"
        @subtitle = "Members who need tickets to #{@next_event.year}"
        @users = User.activated.needs_ticket_to_next_event.paginate(page: params[:page])

      elsif params[:q] == "driving_to_next_event"
        @subtitle = "Members who are driving to #{@next_event.year}"
        @users = User.activated.driving_to_next_event.paginate(page: params[:page])

      elsif params[:q] == "early_arrivals_next_event"
        @subtitle = "Early Arrival Team for #{@next_event.year}"
        @users = User.activated.early_arrivals_next_event.paginate(page: params[:page])

      end

    else
      @subtitle = "All Camp Members"
      @users = User.activated.paginate(page: params[:page])

    end

    respond_to do |format|
      format.html
      format.csv do
        send_data User.all.to_csv
      end
    end


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


  def camp_dues_notification
    @user.send_camp_dues_notification
    flash[:success] = "Notification Sent"
    redirect_to camp_dues_overview_event_url(@next_event)
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
