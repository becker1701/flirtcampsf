class ActivitiesController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_event
  before_action :set_activity, only: [:show, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update, :destroy]

  

  # GET /activities
  def index
    @activities = @event.activities.order(:day, :time)



    # @event.days.each do |day|
    #   instance_variable_set("@#{day.tableize}", @event.activities.by_day(day))
    # end


  end

  # GET /activities/1
  def show
  end

  # GET /activities/new
  def new
    @activity = @event.activities.build(user: current_user)
  end

  # GET /activities/1/edit
  def edit
  end

  # POST /activities
  def create
    # debugger
    @activity = @event.activities.build(activity_params)

    respond_to do |format|
      if @activity.save
        
        format.html do 
          redirect_to event_activities_url(@event)
          flash[:success] = 'Activity was successfully created.'
        end
    
      else
        format.html { render :new }
    
      end
    end
  end

  # PATCH/PUT /activities/1
  def update
    
    respond_to do |format|
      if @activity.update(activity_params)
        format.html do 
          redirect_to event_activities_url(@event)
          flash[:success] = 'Activity was successfully updated.'
        end
    
      else
        format.html { render :edit }
    
      end
    end
  end

  # DELETE /activities/1
  def destroy
    @activity.destroy
    respond_to do |format|
      format.html do
        redirect_to event_activities_url(@event)
        flash[:success] = 'Activity was successfully destroyed.'
      end
  
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_activity
      @activity = @event.activities.find_by(id: params[:id])
    end

    def set_event
      # debugger
      @event = Event.find_by(id: params[:event_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def activity_params
      params.require(:activity).permit(:event_id, :user_id, :publish, :title, :day, :time, :description)
    end

    def correct_user
      # debugger
      unless current_user?(@activity.user) || current_user.admin
        redirect_to event_activities_url(@event) 
      end
    end
end
