require 'test_helper'

class ApplicationTest < ActiveSupport::TestCase


	# #no email
	# test "returns false if no email sent to #email_exists" do
	# 	assert_not Application.email_exists
	# end
		
	# test "returns User if email sent to #email_exists in User table" do
	# 	@user = users(:archer)
	# 	found_user = Application.email_exists(@user.email)

	# 	assert_instance_of User, found_user
	# 	assert @user.email, found_user.email
	# end

	# test "returns Invitation if email sent to #email_exists in Invitation table" do
	# 	@invite = invitations(:one)
	# 	found_user = Application.email_exists(@invite.email)

	# 	assert_instance_of Invitation, found_user
	# 	assert @invite.email, found_user.email
	# end

	# test "returns Member Application if email sent to #email_exists in Member Application table" do
	# 	@member_app = membership_applications(:first)
	# 	found_user = Application.email_exists(@member_app.email)

	# 	assert_instance_of MembershipApplication, found_user
	# 	assert @member_app.email, found_user.email
	# end

	# test "returns false if email sent to #email_exists does not exist" do
	# 	found_user = Application.email_exists("someemailthatisnotinthedatabase@example.com")
	# 	assert_not found_user
	# end

end
