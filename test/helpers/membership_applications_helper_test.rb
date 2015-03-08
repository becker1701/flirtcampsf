require 'test_helper'

class MembershipApplicationsHelperTest < ActionView::TestCase

	def setup
		@member_app = membership_applications(:first)
	end

	test "returns birth_name when playa_name is empty" do
		@member_app.playa_name = " "
		assert_equal display_name(@member_app), "Brian Example"
	end

	test "returns playa_name when playa_name is not empty" do
		# @member_app.playa_name = nil
		assert_equal display_name(@member_app), "Camp Master"
	end

	test "return empty string if both missing" do
		@member_app.playa_name = " "
		@member_app.birth_name = " "
		assert_equal display_name(@member_app), ""
	end

end