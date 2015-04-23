require 'test_helper'

class MembershipApplicationsHelperTest < ActionView::TestCase

	def setup
		@member_app = membership_applications(:first)
	end

	test "returns name when playa_name is empty" do
		@member_app.playa_name = " "
		assert_equal "Brian Example", display_name(@member_app)
	end

	test "returns playa_name when playa_name is not empty" do
		# @member_app.playa_name = nil
		assert_equal display_name(@member_app), "Camp Master"
	end

	test "return empty string if both missing" do
		@member_app.playa_name = " "
		@member_app.name = " "
		assert_equal display_name(@member_app), "(no name)"
	end

	test "returns first name" do
		user = users(:archer)
		user.playa_name = nil
		assert_equal "Archer", display_name(user, first_name_only: true)
	end

end