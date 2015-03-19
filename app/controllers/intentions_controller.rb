class IntentionsController < ApplicationController

	def create
		

		intention_status = params[:status]
		next_event = Event.find_by(id: params[:event])
# debugger
		@intention = current_user.intentions.build(status: intention_status, event: next_event)
		if @intention.save
			redirect_to root_url
		else
			redirect_to root_url
		end
	end

  def edit
  end

  def show
  end

private

	def intention_params
		params.require(:intention).permit(:arrival_date, :departure_date, :transportation, :seats_available, :lodging, :yurt_owner, :yurt_storage, :yurt_panel_size, :yurt_user, :opt_in_meals, :food_restrictions, :logistics, :event)
	end

end
