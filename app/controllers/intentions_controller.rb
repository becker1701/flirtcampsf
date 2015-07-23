class IntentionsController < ApplicationController
	
	before_action :logged_in_user
	before_action :admin_user, only: :edit_storage_tenent
	before_action :get_event
	before_action :get_intention,  only: [:edit, :update, :edit_storage_tenent]
	before_action :correct_user, only: [:edit, :update]

	# before_action :get_next_event, only: [:edit, :update]

	def create
		# binding.pry

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

	def edit_storage_tenent
		# binding.pry
		if params[:intention][:storage_tenent] == "0"
			params[:intention][:camp_due_storage] = 0
		end

		# binding.pry

		if @intention.update_attributes(intention_params)
			flash[:success] = "Storage tenent option updated"
		else
			flash[:danger] = "The storage option update failed"
		end
		redirect_to user_path(@intention.user)
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
		params.require(:intention).permit(:status,
										  :arrival_date,
										  :departure_date,
										  :transportation,
										  :seats_available,
										  :lodging,
										  :yurt_owner,
										  :yurt_storage,
										  :yurt_panel_size,
										  :yurt_user,
										  :opt_in_meals,
										  :food_restrictions,
										  :logistics,
										  :user_id,
										  :event_id,
										  :storage_bikes,
										  :logistics_bike,
										  :logistics_bins,
										  :lodging_num_occupants,
										  :shipping_yurt,
										  :camp_due_storage,
										  :storage_tenent)
		#:tickets_for_sale, 
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
      if !current_user?(@intention.user) && !admin_user?
        redirect_to root_url
      end
    end

	# def get_next_event
	# 	@next_event = Event.find_by(id: @intention.event) if @intention && !@intention.event.nil?
	# end
end
