class EarlyArrivalsController < ApplicationController

	before_action :logged_in_user
	before_action :admin_user
	before_action :get_event
	before_action :get_early_arrival, only: [:destroy]

	def index
		@early_arrivals = @event.early_arrivals.includes(:user)
	end
	
	# def new
	# 	# @ea = @event.early_arrivals.build
	# 	@intentions = Intention.going_to_next_event
	# end

	def create
		# debugger
		@ea = @event.early_arrivals.build(ea_params)
		if @ea.save
			flash[:success] = "Early Arrival member added"
			respond_to do |format|
				format.html {redirect_to event_early_arrivals_url(@event)}
				format.js {}
			end
		else
			redirect_to event_early_arrivals_url(@event)
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
		@event = @next_event || Event.find_by(id: params[:event_id])
	end
end
