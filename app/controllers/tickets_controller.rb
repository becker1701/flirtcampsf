class TicketsController < ApplicationController

	before_action :logged_in_user, only: [:index, :edit, :update]
	before_action :get_event

	def index
		@tickets = @event.tickets.order(:status)
	end

	def new
		@user = User.find_by(id: params[:user_id]) if params[:user_id]
		@ticket = @event.tickets.build
	end

	def create
		@ticket = @event.tickets.build(ticket_params)
		if @ticket.save
			flash[:success] = "Your tickets will be posted to the camp. A buyer will be in touch."
			redirect_to [@event, @ticket]
		else
			render :new
		end

	end

	def show
		@ticket = @event.tickets.find_by(id: params[:id])
		redirect_to root_url if @ticket.nil?
	end

private

	def ticket_params
		params.require(:ticket).permit(:event_id, :name, :email, :admission_qty, :parking_qty, :confirmation_number, :status)
	end

	def get_event
		@event = Event.find_by(id: params[:event_id])
	end

end
