require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

	test "full title helper" do
		assert_equal full_title, "Flirt Camp SF"
		assert_equal full_title("Help"), "Help | Flirt Camp SF"
	end

	#take a text area input and render new line as <br>.  h() in view
	test "textarea newline" do

		assert_nil format_newline
		assert_equal format_newline("abc\ndef"), "abc<br>def".html_safe
	end

	test "strf_day" do
		#TEST: test for nil date, date format output, other types of input
		date = nil
		assert_nil strf_day(date)

		date = "not a date"
		assert_nil strf_day(date)


		date = Date.new(2015, 05, 26)
		assert_equal "Tue, May 26", strf_day(date)

	end

	test "strf_time" do
		#TEST: test for nil time, time format output, other types of input
		time = nil
		assert_nil strf_time(time)

		time = "not a time"
		assert_nil strf_time(time)


		time = Time.new(2015, 05, 26, 12, 0, 0)
		assert_equal "12:00 PM", strf_time(time)
	end

	test "early_arrival_date_presenter" do
		@event = events(:future)
		assert_equal strf_day(@event.early_arrival_date), ea_date_presenter(@event)

		@event.early_arrival_date = nil
		# @event.save
		assert_equal "TBD", ea_date_presenter(@event)
	end


end

