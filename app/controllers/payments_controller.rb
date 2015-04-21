class PaymentsController < ApplicationController
	before_action :logged_in_user
	before_action :admin_user, except: [:index]
	before_action :get_user
  before_action :correct_user, only: :index
	before_action :get_event

  def new
  	# binding.pry
  	@payment = @user.payments.build(event: @next_event)
  end

  def create

  	@payment = @user.payments.build(payment_params)
  	if @payment.save
  		flash[:success] = "Payment saved"
  		redirect_to user_payments_url(@user)
  	else
  		render :new
  	end
  end

  def edit
    @payment = @user.payments.find_by(id: params[:id])
  end

  def update
    @payment = @user.payments.find_by(id: params[:id])
    if @payment.update_attributes(payment_params)
      flash[:success] = "Payment updated"
      redirect_to user_payments_url(@user)
    else
      render :edit
    end
  end

  def index
  	@payments = @user.payments.for_next_event
  end

  def destroy
    @payment = @user.payments.find_by(id: params[:id]).destroy
    flash[:success] = "Payment deleted"
    redirect_to user_payments_url(@user)
  end


private

	def payment_params
		params.require(:payment).permit(:event_id, :payment_date, :amount, :description)
	end

	def get_user
		@user = User.find_by(id: params[:user_id])
		if @user.nil?
			flash[:danger] = "User not found"
			redirect_to users_url
		end		
	end

  def correct_user
    # unless current_user.admin?
      redirect_to root_url if !current_user?(@user) && !current_user.admin?
    # end
  end

	def get_event
		# binding.pry
		@event = next_event
	end
end
