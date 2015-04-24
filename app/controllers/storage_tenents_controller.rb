class StorageTenentsController < ApplicationController
  
  	before_filter :logged_in_user
	before_filter :admin_user
	before_filter :get_event

  def index

  	@tenents = @event.intentions.where(yurt_owner: true)

  end


private

	def get_event
		@event = Event.find_by(id: params[:event_id])
	end
end
