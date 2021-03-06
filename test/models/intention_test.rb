require 'test_helper'

class IntentionTest < ActiveSupport::TestCase

	def setup
		@user = users(:brian)
		@intention = Intention.new(
			  user: users(:brian),
			  event: events(:future),
			  status: 1,
			  arrival_date: Date.today + 120.days,
			  departure_date: Date.today + 125.days,
			  transportation: 1,
			  seats_available: 1,
			  lodging: 1,
			  yurt_owner: true,
			  yurt_storage: true,
			  yurt_panel_size: 1,
			  yurt_user: "Lilly and Michelle",
			  opt_in_meals: true,
			  food_restrictions: "none",
			  logistics: "I need a few bins transported",
			  tickets_for_sale: 1,
			  storage_bikes: 1,
			  logistics_bike: 2,
			  logistics_bins: 2,
			  lodging_num_occupants: 2,
			  shipping_yurt: false,
			  storage_tenent: false,
			  camp_due_storage: 75
			  )
	end

	test "user has intention" do
		assert_not @user.intentions.empty?
	end

	test "valid with user" do
		@intention.user = nil
		assert_not @intention.valid?
	end

	test "invalid without user" do
		assert @intention.valid?
	end

	test "invalid without event_id" do
		@intention.event = nil
		assert_not @intention.valid?
	end

	test "transportation enum" do
		@intention.transportation = :driving
		assert @intention.valid?

		@intention.transportation = :riding_with_someone
		assert @intention.valid?

		@intention.transportation = :bus
		assert @intention.valid?

		@intention.transportation = :walk
		assert @intention.valid?

		@intention.transportation = :flying_in
		assert @intention.valid?

		@intention.transportation = :other_transportation
		assert @intention.valid?

	end

	test "status enum" do
		@intention.status = :going_has_ticket
		assert @intention.valid?
		@intention.status = :going_needs_ticket
		assert @intention.valid?
		@intention.status = :not_going_has_ticket
		assert @intention.valid?
		@intention.status = :not_going_no_ticket
		assert @intention.valid?
  	end

	test "lodging enum" do
		@intention.lodging = :tent
		assert @intention.valid?
		@intention.lodging = :yurt
		assert @intention.valid?
		@intention.lodging = :car
		assert @intention.valid?
		@intention.lodging = :other_lodging
		assert @intention.valid?
  	end


  	test "invlalid without status" do
  		@intention.status = nil
  		assert_not @intention.valid?
  	end

  test "going/not_going boolean" do
    # event = events(:future)
    # debugger
    @intention.update_attribute(:status, :going_has_ticket)
    assert @intention.going?
    @intention.update_attribute(:status, :going_needs_ticket)
    assert @intention.going?
    @intention.update_attribute(:status, :not_going_has_ticket)
    assert_not @intention.going?
    @intention.update_attribute(:status, :not_going_no_ticket)
    assert_not @intention.going?
  end

	test "invalid if arrival_date after departure_date" do
		@intention.arrival_date = @intention.departure_date + 1.day
		assert_not @intention.valid?
		assert_includes @intention.errors.full_messages, "Arrival date must be before departure date"
	end

	test "users returned for next event" do 
		#users that have intentions created for next event
		intentions_for_next_event = Intention.for_next_event
		assert_equal 4, intentions_for_next_event.count
		assert_includes intentions_for_next_event, intentions(:for_brian)
		assert_includes intentions_for_next_event, intentions(:for_archer)
		assert_includes intentions_for_next_event, intentions(:for_kurt)
		assert_includes intentions_for_next_event, intentions(:for_elisabeth)

	end 

	test "users returned for going to next event" do 
		#users that have intentions created for next event
		# other_user = users(:kurt)
		# other_user_intention = intentions(:for_kurt)
		# other_user_intention.status = 3
		# other_user_intention.save!
		#should be 2 
		intentions_for_going_to_next_event = Intention.going_to_next_event

		assert_equal 2, intentions_for_going_to_next_event.count
		
		assert_includes intentions_for_going_to_next_event, intentions(:for_brian)
		assert_includes intentions_for_going_to_next_event, intentions(:for_archer)
		refute_includes intentions_for_going_to_next_event, intentions(:for_kurt)
		refute_includes intentions_for_going_to_next_event, intentions(:for_elisabeth)

	end 


	test "users returned for not going to next event" do 
		intentions_for_not_going_to_next_event = Intention.not_going_to_next_event

		assert_equal 2, intentions_for_not_going_to_next_event.count
		
		refute_includes intentions_for_not_going_to_next_event, intentions(:for_brian)
		refute_includes intentions_for_not_going_to_next_event, intentions(:for_archer)
		assert_includes intentions_for_not_going_to_next_event, intentions(:for_kurt)
		assert_includes intentions_for_not_going_to_next_event, intentions(:for_elisabeth)

	end 


	test "invalid when camp_due_storage is nil" do
		@intention.camp_due_storage = nil
		assert_not @intention.valid?
	end

	test "storage dues returns 0 for yurt owner not storage tenant" do
		@intention.yurt_owner = true
		assert @intention.yurt_owner
		@intention.storage_tenent = false
		@intention.camp_due_storage = 75
		assert_equal 0, @intention.storage_amount_due
	end

	test "storage dues returns 75 for yurt owner with storage tenant" do
		@intention.yurt_owner = true
		assert @intention.yurt_owner
		@intention.storage_tenent = true
		@intention.camp_due_storage = 75
		assert_equal 75, @intention.storage_amount_due

		#if the camp_due_storage is 0 for some reason, return 0
		@intention.camp_due_storage = 0
		assert_equal 0, @intention.storage_amount_due		
	end

	test "storage dues returns 0 for non yurt owner not storage tenant" do
		@intention.yurt_owner = false
		assert_not @intention.yurt_owner
		@intention.storage_tenent = false
		@intention.camp_due_storage = 75
		assert_equal 0, @intention.storage_amount_due
	end

	test "storage dues returns 0 for non yurt owner with storage tenant" do
		#this should not happen
		@intention.yurt_owner = false
		assert_not @intention.yurt_owner
		@intention.storage_tenent = true
		@intention.camp_due_storage = 75
		assert_equal 0, @intention.storage_amount_due
	end


	# test "#total_yurts_to_ship returns count for event" do
	# 	event= events(:future)
	# 	assert_equal 2, Intention.total_yurts_to_ship(event)

	# 	yurts_to_ship = Intention.where(event: event, shipping_yurt: true)
	# 	assert_not yurts_to_ship.nil?
	# 	assert_equal 2, yurts_to_ship.count	
	# end


end
