require 'test_helper'

class UserActivationResetTest < ActionDispatch::IntegrationTest

	def setup
		@na_user = users(:not_activated)
		@user = users(:brian)
		ActionMailer::Base.deliveries.clear
	end



	test "activation reset for non acivated account" do

		#User visits login page
		get login_path
		#User tries to login to a non activated account
		post login_path, {email: @na_user.email, password: 'password'}
		#User is taken back to login page with a new link to re-send activation email (only for non activated accounts)
		#Not logged in
		assert_not is_logged_in?
		assert_template 'sessions/new'
		assert_not flash.empty?
		assert_select "div.reset_account_activation"
		assert_select 'a[href=?]', new_account_activation_path

		get new_account_activation_path
		assert_template 'account_activations/new'

		assert flash.empty?, "Flash message should not be present"

		#user fills in invalid email
		post account_activations_path, account_activation: { email: 'invalid email' }
		assert_template 'account_activations/new'
		assert_not flash.empty?

		#user fills in valid email, but is already activated
		post account_activations_path, account_activation: { email: @user.email }
		assert_redirected_to login_url
		assert_not flash.empty?
		assert @user.activated?

		#User fills in valid email
		old_activation_digest = @na_user.activation_digest

		post account_activations_path, account_activation: { email: @na_user.email }
		
		na_user = assigns(:user)

		#Digest reset
		assert_not is_logged_in?
		assert_not na_user.activated?
		assert_redirected_to root_url
		assert_not flash.empty?

		#reset activation_digest
		# debugger
		assert_not_equal old_activation_digest, na_user.reload.activation_digest
		assert_not na_user.activation_token.nil?

		#Email sent
		assert_equal 1, ActionMailer::Base.deliveries.count
		mail = ActionMailer::Base.deliveries.last
		assert mail.subject, "Activate your account"
		assert mail.to, na_user



		#User clicks link in email
		


#*******test for invalid token
		get edit_account_activation_path('invalid token'), email: na_user.email
		assert_not is_logged_in?
		assert_redirected_to root_url
		follow_redirect!
		assert_not flash.empty?
		assert_select "div.alert-danger", text: "Invalid activation link."

#*******test for invalid email
		get edit_account_activation_path(na_user.activation_token), email: 'onvalid email'
		assert_not is_logged_in?
		assert assert_redirected_to root_url
		follow_redirect!
		assert_not flash.empty?
		assert_select 'div.alert-danger', text: "Invalid activation link."

		#test for valid token and email
		get edit_account_activation_path(na_user.activation_token), email: na_user.email
		assert is_logged_in?
		assert assert_redirected_to root_path#na_user
		assert_not flash.empty?
		assert na_user.reload.activated?

	end


end
