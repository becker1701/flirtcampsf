class StaticPagesController < ApplicationController
  def home
  	@next_event = Event.next_event
  end

  def about
  end

  def contact
  end

  def new_member_app
  end
  
private

end
