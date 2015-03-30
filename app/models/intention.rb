class Intention < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :event

  validates :status, :user_id, :event_id, presence: true
  validate :arrival_date_before_departure_date

  enum status: { going_has_ticket: 1, going_needs_ticket: 2, not_going_has_ticket: 3, not_going_no_ticket: 4 }
  enum lodging: { tent: 1, yurt: 2, car: 3, other_lodging: 4 }
  enum transportation: { driving: 1, carpool: 2, bus: 3, walk: 4, other_transportation: 5 }

  def Intention.for_next_event
  	where(event: Event.next_event)
  end

  def Intention.going_to_next_event
    #TODO: test Intention.going
    for_next_event.where(status: [1,2])
  end 

	def going?
		# debugger
		if self.going_has_ticket? || self.going_needs_ticket?
			true
		else
			false
		end
	end

private

  def arrival_date_before_departure_date
    if self.arrival_date && self.departure_date && self.arrival_date > self.departure_date
      errors.add(:arrival_date, "must be before departure date")
    end
  end

end
