class Intention < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :event

  validates :user_id, :event_id, presence: true

  enum status: { going_has_ticket: 1, going_needs_ticket: 2, not_going_has_ticket: 3, not_going_no_ticket: 4 }
  enum lodging: { tent: 1, yurt: 2, car: 3, other_lodging: 4 }
  enum transportation: { driving: 1, carpool: 2, bus: 3, walk: 4, other_transportation: 5 }

# arrival_date
# departure_date
# transportation
# seats_available
# lodging
# yurt_owner
# yurt_storage
# yurt_panel_size
# yurt_user
# opt_in_meals
# food_restrictions
# logistics
# event_id


end
