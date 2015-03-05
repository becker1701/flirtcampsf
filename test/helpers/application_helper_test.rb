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

end

