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
		skip
	end

	test "strf_time" do
		#TEST: test for nil time, time format output, other types of input
		skip
	end


end

