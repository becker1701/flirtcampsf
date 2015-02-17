require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

	test "full title helper" do
		assert_equal full_title, "Ruby on Rails Sample Tutorial App"
		assert_equal full_title("Help"), "Help | Ruby on Rails Sample Tutorial App"
	end

	#take a text area input and render new line as <br>.  h() in view
	test "textarea newline" do

		assert_nil format_newline
		assert_equal format_newline("abc\ndef"), "abc<br>def".html_safe
	end

end

