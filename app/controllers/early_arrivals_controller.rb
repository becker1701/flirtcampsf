class EarlyArrivalsController < ApplicationController

	before_action :logged_in_user
	before_action :admin_user
	before_action :get_event
	before_action :get_early_arrival, only: [:destroy]

	def index
		@early_arrivals = @event.early_arrivals.includes(:user)
	end
	
	def new

	end

	def create
		debugger
		@ea = @event.early_arrivals.build(ea_params)
		if @ea.save
			flash[:success] = "Early Arrival member added"
			redirect_to event_early_arrivals_url(@event)
		else
			render :new
		end
	end

	def destroy
		@ea.destroy
		redirect_to event_early_arrivals_url(@event)
	end

private

	def ea_params
		params.require(:early_arrival).permit(:user_id, :event_id)
	end

	def get_early_arrival
		@ea = @event.early_arrivals.find_by(id: params[:id])
	end

	def get_event
		@event = Event.find_by(id: params[:event_id])
	end
end
