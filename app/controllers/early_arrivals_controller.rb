class EarlyArrivalsController < ApplicationController

	before_action :logged_in_user
	before_action :admin_user
	before_action :get_event
	before_action :get_user, only: [:create]
	before_action :get_early_arrival, only: [:destroy]
	

	def index
		@early_arrivals = @event.early_arrival_list
	end

	def create
		# debugger
		@ea = @event.early_arrivals.build(ea_params)
		if @ea.save
			# flash[:success] = "Early Arrival member added"
			redirect_to @user
		else
			redirect_to event_early_arrivals_url(@event)
		end
	end

	def destroy
		@user = @ea.user
		@ea.destroy
		redirect_to @user
	end

private

	def ea_params
		params.require(:early_arrival).permit(:user_id, :event_id)
	end

	def get_user
		@user = User.find_by(id: params[:early_arrival][:user_id]) unless params[:early_arrival][:user_id].nil?
		# debugger
	end

	def get_early_arrival
		@ea = @event.early_arrivals.find_by(id: params[:id])
	end

	def get_event
		@event = @next_event || Event.find_by(id: params[:event_id])
	end
end
