class IntentionsController < ApplicationController

  before_action :logged_in_user
  before_action :admin_user, only: [:edit_storage_tenent, :new]
  before_action :get_event
  before_action :get_intention,  only: [:edit, :update, :edit_storage_tenent]
  before_action :correct_user, only: [:edit, :update]

  # before_action :get_next_event, only: [:edit, :update]

  def new
    # binding.pry
    if params['user']
      user = User.find_by(id: params['user'].to_i)
    end

    if user
      @intention = @event.intentions.build(user_id: user.id)
    else
      flash.now[:danger] = "User not found"
      redirect_to :back
    end
  end

  def create
    binding.pry

    if params[:intention]
      user = User.find_by(id: intention_params[:user_id]) || current_user
      intention_status = intention_params[:status]
    else
      user = current_user
      intention_status = params[:status]
    end

    # next_event = Event.find_by(id: params[:event])

    @intention = @event.intentions.build(status: intention_status, user: user, opt_in_meals: true)
    if @intention.save
      if intention_status == "not_going_no_ticket"
        flash[:success] = "You will be missed..."
        redirect_to root_url
      else
        if admin_user?
          flash[:success] = "Intention has been created for #{user.name}"
          redirect_to camp_dues_overview_event_path(@event)
        else
          flash[:success] = "Oh Yeah!!  Please let me know some omre specifics.  You can come back to this at any time to update."
          redirect_to edit_event_intention_url(@event, @intention)
        end
      end
    else
      flash.now[:danger] = "Please correct the errors in the form."
      render :new
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
      if admin_user?
        flash[:success] = "Intentions updated for #{@intention.user.name}"
        redirect_to camp_dues_overview_event_path(@event)
      else
        flash[:success] = "Intentions updated."
        redirect_to root_url
      end
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
                      # :opt_in_meals,
                      :lodging_footprint,
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
                      :storage_tenent,
                      :vehicle_type,
                      :interested_in_rental_van,
                      :stryke_confirmation)
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
  #   @next_event = Event.find_by(id: @intention.event) if @intention && !@intention.event.nil?
  # end
end
