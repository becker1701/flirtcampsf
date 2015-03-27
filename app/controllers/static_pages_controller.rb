class StaticPagesController < ApplicationController
    
    before_action :next_event, only: :home

  def home

  	if logged_in? && @next_event
  		@intention = current_user.next_event_intention || @next_event.intentions.build(user: current_user)
      # debugger
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
