class Payment < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  scope :for_next_event, -> { where(event: Event.next_event) }

  validates :payment_date, :amount, :event_id, :user_id, presence: true

end
