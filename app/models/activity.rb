class Activity < ActiveRecord::Base
  belongs_to :event
  belongs_to :user

  # TODO: scope by day and time

  validates :event_id, :day, :time, :title, presence: true

  def Activity.by_day(date)
  	where(day: date)
  end

end
