class EventsController < ApplicationController

	before_action :logged_in_user
	before_action :admin_user


  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      flash[:success] = ")'( Event Added!"
      redirect_to root_url
    else
      render :new
    end
    
  end

  def show
  end

  def edit
    @event = Event.find_by(id: params[:id])
  end

  def update
    @event = Event.find_by(id: params[:id])
    if @event.update_attributes(event_params)
      flash[:success] = ")'( Event updated."
      redirect_to root_url
    else
      render :edit
    end
  end


private

  def event_params
    params.require(:event).permit(:year, :start_date, :end_date, :theme, :camp_address, :early_arrival_date)
  end

end
