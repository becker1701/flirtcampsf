class IntentionsController < ApplicationController
	
	before_action :logged_in_user
	before_action :get_event
	before_action :get_intention,  only: [:edit, :update]
	before_action :correct_user, only: [:edit, :update]

	# before_action :get_next_event, only: [:edit, :update]

	def create
		# debugger
		intention_status = params[:status]
		# next_event = Event.find_by(id: params[:event])

		@intention = @event.intentions.build(status: intention_status, user: current_user)
		if @intention.save
			if intention_status == "not_going_no_ticket"
				redirect_to root_url	
			else
				redirect_to edit_event_intention_url(@event, @intention)
			end
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
		params.require(:intention).permit(:status, :arrival_date, :departure_date, :transportation, :seats_available, :lodging, :yurt_owner, :yurt_storage, :yurt_panel_size, :yurt_user, :opt_in_meals, :food_restrictions, :logistics, :user_id, :event_id, :tickets_for_sale)
	end

	def get_intention
		# debugger
		@intention = @event.intentions.find_by(id: params[:id])
	end

	def get_event
		@event = Event.find_by(id: params[:event_id])
	end

    def correct_user
      # debugger
      unless current_user?(@intention.user)
        redirect_to root_url
      end
    end

	# def get_next_event
	# 	@next_event = Event.find_by(id: @intention.event) if @intention && !@intention.event.nil?
	# end
end
