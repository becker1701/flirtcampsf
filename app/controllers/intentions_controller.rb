class IntentionsController < ApplicationController

	before_action :get_intention,  only: [:edit, :update]
	before_action :get_next_event, only: [:edit, :update]

	def create
		intention_status = params[:status]
		next_event = Event.find_by(id: params[:event])

		@intention = current_user.intentions.build(status: intention_status, event: next_event)
		if @intention.save
			redirect_to edit_intention_url @intention
		else
			redirect_to root_url
		end
	end

	def edit
	end

	def update
		if @intention.update_attributes(intention_params)
			flash[:success] = "Intentions updated."
			redirect_to root_url
		else
			flash[:danger] = "Your intentions were not saved."
			render :edit
		end
	end

	def show
	end


private

	def intention_params
		params.require(:intention).permit(:status, :arrival_date, :departure_date, :transportation, :seats_available, :lodging, :yurt_owner, :yurt_storage, :yurt_panel_size, :yurt_user, :opt_in_meals, :food_restrictions, :logistics, :event, :tickets_for_sale)
	end

	def get_intention
		# debugger
		@intention = current_user.intentions.find_by(id: params[:id])
	end

	def get_next_event
		@next_event = Event.find_by(id: @intention.event) if @intention && !@intention.event.nil?
	end
end
