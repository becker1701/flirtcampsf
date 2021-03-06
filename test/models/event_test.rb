require 'test_helper'

class EventTest < ActiveSupport::TestCase

	def setup
		# Event.destroy_all
		@event = Event.new(year: "2015", start_date: Date.today + 150.days, end_date: Date.today + 157.days, theme: "Some Theme", camp_address: "9:00 & F", early_arrival_date: Date.today + 145.days, camp_dues: 100, camp_dues_food: 50)
	end

	test "is valid" do
		assert @event.valid?
	end

	test "invalid without year" do
		@event.year = " "
		assert_not @event.valid?
	end

	test "invalid if end_date before start_date" do
		@event.start_date = @event.end_date + 1.day
		assert_not @event.valid?
		assert_includes @event.errors.full_messages, "Start date must be before event end date"
	end

	test "valid if no early arrival date" do
		@event.early_arrival_date = nil
		assert @event.valid?
	end

	test "invalid if early_arrival_date after start_date" do
		@event.early_arrival_date = @event.start_date + 1.day
		assert_not @event.valid?
		assert_includes @event.errors.full_messages, "Early arrival date must be before event start date"
	end



	test "return event if not passed end date" do
		Event.destroy_all
		@event.save
		event_past = @event.dup

		event_past.start_date = Date.today - 100.days
		event_past.end_date = event_past.start_date + 7.days
		event_past.save
		assert_equal @event, Event.next_event
	end

	test "return no event if end date has passed" do
		Event.destroy_all
		@event.start_date = Date.today - 100.days
		@event.end_date = @event.start_date + 7.days
		@event.save

		assert_equal nil, Event.next_event
	end


	test "return current event if end date has passed" do
		Event.destroy_all
		@event.start_date = Date.today - 4.days
		@event.early_arrival_date = @event.start_date - 1.day
		@event.end_date = Date.today + 7.days
		@event.save
		assert_equal @event, Event.next_event
	end

	test "event date list" do
		start_day = @event.start_date
		end_day = @event.end_date

		date_range = (start_day..end_day).to_a
		num_days = date_range.size
		event_days = @event.days
		assert_equal num_days, event_days.count

		date_range.each do |date|
			assert_includes event_days, date.strftime("%a, %b %-e")
		end
	end

	test "early arrival association exists" do
		# @event.save
		assert @event.early_arrivals.empty?
	end

	test "#extended_date_range" do
		edr = @event.extended_date_range
		assert_includes edr, @event.early_arrival_date - 2.days
		assert_includes edr, @event.start_date
		assert_includes edr, @event.end_date
		assert_includes edr, @event.end_date + 2.days
		assert_operator 18, :>=, edr.size
	end

	test "#extended date range without EAD" do
		@event.early_arrival_date = nil
		@event.save

		edr = @event.extended_date_range
		assert_includes edr, @event.start_date - 7.days
		assert_includes edr, @event.start_date
		# assert_includes edr, @event.end_date
		# assert_includes edr, @event.end_date + 2.days
		assert_operator 18, :>=, edr.size
	end

	test "#extended date range without end_date" do
		@event.end_date = nil
		@event.save

		edr = @event.extended_date_range
		assert_includes edr, @event.early_arrival_date - 2.days
		assert_includes edr, @event.early_arrival_date
		assert_includes edr, @event.start_date
		assert_includes edr, @event.start_date + 3.days
		# assert_operator 18, :>=, edr.size
	end

	test "#extended date range without end_date and early_arrival_date" do
		@event.end_date = nil
		@event.early_arrival_date = nil
		@event.save

		edr = @event.extended_date_range
		assert_includes edr, @event.start_date - 3.days
		assert_includes edr, @event.start_date + 3.days
		# assert_operator 18, :>=, edr.size
	end

	test "invlalid without start date" do
		@event.start_date = nil
		assert_not @event.valid?
	end

	test "invalid if camp_dues nil" do
		@event.camp_dues = nil
		assert_not @event.valid?
	end

	test "invalid if camp_dues_food is nil" do
		@event.camp_dues_food = nil
		assert_not @event.valid?
	end

	test "#count_yurts_to_ship to return 2 for event" do

		assert_equal 2, events(:future).count_yurts_to_ship
		assert_equal 0, @event.count_yurts_to_ship
	end

	test "#count_yurt_storage_requested to return 3 for event" do
		assert_equal 3, events(:future).count_yurt_storage_requested
		assert_equal 0, @event.count_yurt_storage_requested
	end

	test "#count_tenant_after_event to return 3 for event" do
		assert_equal 3, events(:future).count_storage_tenants
		assert_equal 0, @event.count_storage_tenants
	end

	test "#sum_storage_dues is 225 for event" do
		assert_equal 225, events(:future).sum_storage_dues
	end

end
