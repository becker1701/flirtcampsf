class StaticPagesController < ApplicationController
    
    before_action :next_event, only: :home

  def home

  	if logged_in?
      # debugger
  		@intention = current_user.next_event_intention || current_user.intentions.build
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
