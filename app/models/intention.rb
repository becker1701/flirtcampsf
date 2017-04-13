class Intention < ActiveRecord::Base

  belongs_to :user
  belongs_to :event

  scope :for_next_event, -> { joins(:event).merge(Event.next_event) }

  validates :status, :user_id, :event_id, :camp_due_storage, presence: true
  validate :arrival_date_before_departure_date

  enum status: { going_has_ticket: 1, going_needs_ticket: 2, not_going_has_ticket: 3, not_going_no_ticket: 4 }

  enum lodging: { tent: 1, yurt: 2, car: 3, other_lodging: 4 }
  enum transportation: { driving: 1, riding_with_someone: 2, bus: 3, walk: 4, flying_in: 5, other_transportation: 6 }

  def Intention.for_next_event
    where(event: Event.next_event)
  end

  def Intention.going_to_next_event
    #TODO: test Intention.going
    for_next_event.where(status: [1,2])
  end

  def Intention.not_going_to_next_event
    #TODO: test Intention.going
    for_next_event.where(status: [3,4])
  end

  def going?
    # debugger
    if self.going_has_ticket? || self.going_needs_ticket?
      true
    else
      false
    end
  end

  def storage_amount_due
    if storage_tenent && yurt_owner
      camp_due_storage
    else
      0
    end
  end

  # def self.total_yurts_to_ship(event)
  #   where(event: event, shipping_yurt: true).count(:shipping_yurt)
  # end





private

  def arrival_date_before_departure_date
    if self.arrival_date && self.departure_date && self.arrival_date > self.departure_date
      errors.add(:arrival_date, "must be before departure date")
    end
  end

end
