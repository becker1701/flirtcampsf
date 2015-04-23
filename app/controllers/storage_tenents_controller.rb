class StorageTenentsController < ApplicationController
  
	before_filter :admin_user
	before_filter :get_event

  def index

  	@tenents = Intention.for_next_event.where(yurt_owner: true)

  end


private

	def get_event
		@event = next_event
	end
end
