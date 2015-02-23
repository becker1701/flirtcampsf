require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

	def setup
		@user = users(:brian)
		remember(@user)
	end


	#testing current_user
	#1: Test current_user is correct if session is nil
	#2: Test current_user returns nil when remember_token is wrong
	#
	test "current_user returns correct user when session is nil" do
		assert_equal @user, current_user
		assert is_logged_in?
	end

	test "current_user returns nil when remember_token is wrong" do
		@user.update_attribute(:remember_digest, User.digest(User.new_token))
		assert_nil current_user
	end

end