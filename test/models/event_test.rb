require 'test_helper'

class EventTest < ActiveSupport::TestCase

	def setup
		Event.delete_all
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
		skip
	end

	test "return event if not passed end date" do
		@event.save
		event_past = @event.dup

		event_past.start_date = Date.today - 100.days
		event_past.end_date = event_past.start_date + 7.days
		event_past.save
		assert_equal @event, Event.next_event
	end

	test "return no event if end date has passed" do
		# Event.delete_all
		@event.start_date = Date.today - 100.days
		@event.end_date = @event.start_date + 7.days
		@event.save

		assert_equal nil, Event.next_event
	end


	test "return current event if end date has passed" do
		@event.start_date = Date.today - 4.days
		@event.end_date = Date.today + 7.days
		@event.save

		assert_equal @event, Event.next_event
	end


end
