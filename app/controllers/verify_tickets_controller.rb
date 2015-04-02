class VerifyTicketsController < ApplicationController
  def edit
  	@ticket = Ticket.find_by(email: params[:email], id: params[:ticket_id])
  	if @ticket && @ticket.authenticated?(:verification, params[:id])
  		@ticket.verified!
  		flash[:success] = "Thank you! Your tickets are now listed"
  		redirect_to event_ticket_url(@ticket.event, @ticket)
  	else
  		flash[:danger] = "Something went wrong"
  		redirect_to root_url
  	end

  	
  end
end
