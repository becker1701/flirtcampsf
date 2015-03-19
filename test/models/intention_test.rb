require 'test_helper'

class IntentionTest < ActiveSupport::TestCase

	def setup
		@user = users(:brian)
		@intention = intentions(:one)
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

		@intention.transportation = :carpool
		assert @intention.valid?

		@intention.transportation = :bus
		assert @intention.valid?

		@intention.transportation = :walk
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


  	test "invalid if departure date is before arrival date" do
  		skip
  	end

end
