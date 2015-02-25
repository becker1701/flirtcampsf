require 'test_helper'

class UserEditsTest < ActionDispatch::IntegrationTest

	def setup 
		@user = users(:brian)
	end

	def teardown

	end

	test "unsuccessful update with invalid information" do
		log_in_as @user
		get edit_user_path(@user)
		assert_template 'users/edit'
		patch user_path(@user), user: {name: "  ", email: "different_email.example.com", password: '12', password_confirmation: '56'}
		assert_template 'users/edit'
	end

	test "successful update with valid information" do
		log_in_as @user
		get edit_user_path(@user)
		assert_template 'users/edit'
		
		new_name = "Different User"
		new_email = "different_email@example.com"
		new_password = ''

		patch user_path(@user), user: {name: new_name, email: new_email, password: new_password, password_confirmation: ''}
		
		assert_not flash.empty?
		assert_redirected_to @user
		@user.reload
		assert_equal @user.name, new_name
		assert_equal @user.email, new_email

	end
end
