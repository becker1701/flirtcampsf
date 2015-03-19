class StaticPagesController < ApplicationController
  def home

  	@next_event = Event.next_event

  	if logged_in?
      # debugger
  		@intention = current_user.intentions.find_by(event: @next_event) || current_user.intentions.build
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
