class StaticPagesController < ApplicationController

    before_action :next_event, only: :home

  def home
    if logged_in? && @next_event
# binding.pry
      if current_user.intentions.empty?
        @intention = current_user.intentions.build(event: @next_event) #unless @next_event.camp_closed
      else
        @intention = current_user.next_event_intention
      end

      @payments = current_user.payments.where(event: @next_event)
      @early_arrivals = EarlyArrival.next_event_early_arrivals
    end
  end

  def about
  end

  def contact
  end

  def new_member_app
  end

private

end
