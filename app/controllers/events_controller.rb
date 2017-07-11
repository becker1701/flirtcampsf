class EventsController < ApplicationController

  before_action :logged_in_user
  before_action :admin_user


  def index
    @events = Event.all.order(start_date: :desc)
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      flash[:success] = ")'( Event Added!"
      redirect_to events_url
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
      redirect_to events_url
    else
      render :edit
    end
  end

  def destroy
    @event = Event.find_by(id: params[:id])
    @event.destroy
    # flash[:success] = "Event removed."
    redirect_to events_url
  end

  def camp_dues_overview
    @event = Event.find_by(id: params[:id])
    redirect_to users_path if @event.nil?

    @users = User.all.order(:name)
  end

private

  def event_params
    params.require(:event).permit(:year, :start_date, :end_date, :theme, :camp_address, :early_arrival_date, :camp_dues, :camp_dues_food, :organizer_id, :accepting_apps, :camp_dues_mail, :camp_dues_paypal, :archive, :camp_closed)
  end

end
