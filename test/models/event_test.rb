require 'test_helper'

class EventTest < ActiveSupport::TestCase

	def setup
		# Event.destroy_all
		@event = Event.new(year: "2015", start_date: Date.today + 150.days, end_date: Date.today + 157.days, theme: "Some Theme", camp_address: "9:00 & F", early_arrival_date: Date.today + 145.days)
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

end
