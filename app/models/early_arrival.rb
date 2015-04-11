class EarlyArrival < ActiveRecord::Base
  
  belongs_to :event
  belongs_to :user

  def self.next_event_early_arrivals
  	includes(:user).where(event: Event.next_event)
  end

  validates :user_id, :event_id, presence: true

  
end
