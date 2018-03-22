class Activity < ActiveRecord::Base
  belongs_to :event
  belongs_to :user

  # TODO: scope by day and time

  validates :event_id, :day, :time, :end_time, :title, presence: true
  validate :end_time_valid

  def Activity.by_day(date)
    where(day: date)
  end

  def time_range
    return time.strftime("%I:%M %p") unless end_time

    "#{time.strftime("%I:%M %p")} - #{end_time.strftime("%I:%M %p")}"
  end

private

  def time_comparison
    s_time = Time.new(day.year, day.month, day.day, time.hour, time.min)
    e_time = Time.new(day.year, day.month, day.day, end_time.hour, end_time.min)
    s_time <=> e_time
  end

  def end_time_valid
    #
    errors.add(:end_time, "must be later than start time.") if time_comparison == 1
  end

end
