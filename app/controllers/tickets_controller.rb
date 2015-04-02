class TicketsController < ApplicationController

	before_action :logged_in_user, only: [:index, :edit, :destroy]
	before_action :admin_user, only: :destroy
	before_action :get_event

	def index
		if admin_user?
			@tickets = @event.tickets.order(:status)
		else
			@tickets = @event.tickets.verified.order(:status)
		end
	end

	def new
		@user = User.find_by(id: params[:user_id]) if params[:user_id]
		@ticket = @event.tickets.build
	end

	def create
		@ticket = @event.tickets.build(ticket_params)
		if @ticket.save

			if logged_in? 
				@ticket.verified!
				flash[:success] = "Your tickets have been listed"
				redirect_to [@event, @ticket]
			else
				flash[:info] = "An email has been sent to verify your email"
				@ticket.send_verification_email	
				redirect_to root_url			
			end

			
		else
			render :new
		end

	end

	def edit	
		@ticket = @event.tickets.find_by(id: params[:id])
		if params[:status] == "sold"
			@ticket.update_attribute(:status, :sold)
		end
		redirect_to event_tickets_path(@event)
	end

	def show
		@ticket = @event.tickets.find_by(id: params[:id])
		redirect_to root_url if @ticket.nil?
	end

	def destroy
		# debugger
		@event.tickets.find_by(id: params[:id]).destroy
		flash[:success] = "Ticket removed"
		redirect_to event_tickets_url(@event)
	end

private

	def ticket_params
		params.require(:ticket).permit(:event_id, :name, :email, :admission_qty, :parking_qty, :confirmation_number, :status)
	end

	def get_event
		@event = Event.find_by(id: params[:event_id])
	end

end
