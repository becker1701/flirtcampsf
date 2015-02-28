require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:brian)
		
		
		@not_activated = users(:not_activated)

		ActionMailer::Base.deliveries.clear
	end

	test "password reset request for non activaed user" do
		get new_password_reset_path

		post password_resets_path, password_reset: {email: @not_activated.email}

		assert_not is_logged_in?
		assert_redirected_to root_url
		assert_not flash.empty?
		# user = assigns(:user)

		# assert_not user.activation_token.nil?
		# assert_redirected_to root_path
		# assert_not is_logged_in?
		# assert_equal 1, ActionMailer::Base.deliveries.count
		# mail = ActionMailer::Base.deliveries.last
		# assert mail.subject, "Activate your account"
		# ActionMailer::Base.deliveries.clear

		
		# log_in_as user
		# assert_redirected_to root_url
		# assert_not is_logged_in?
		# assert_not flash.empty?

		# #visit URL for activating account

		# #try to activate with incorrect token
		# get edit_account_activation_path('incorrect token', email: user.email)
		# assert_redirected_to root_url
		# assert_not is_logged_in?
		# assert_not flash.empty?

		# #try valid token and wrong email
		# get edit_account_activation_path(user.activation_token, email: 'wrong')
		# assert_redirected_to root_url
		# assert_not is_logged_in?
		# assert_not flash.empty?

		# #try with correct activation token and email
  		
  # 		get edit_account_activation_path(user.activation_token, email: user.email)
  # 		debugger
  # 		user.reload
		# assert user.activated?
		# follow_redirect!
		# assert_template 'users/show'
		# assert_not flash.empty?
		# assert is_logged_in?

	end


	test "password resets with invalid information" do
		
		get new_password_reset_path
		assert_template 'password_resets/new'

		assert @user.reset_digest.nil?
		assert @user.reset_sent_at.nil?

		#invalid email
		post password_resets_path, password_reset: {email: 'invalid_email'}
		assert_template 'password_resets/new'
		assert_not flash.empty?
		assert_equal 0, ActionMailer::Base.deliveries.count

		



		#valid email sends email and sets reset attributes
		post password_resets_path, password_reset: {email: @user.email}
		assert_equal 1, ActionMailer::Base.deliveries.count
		mail = ActionMailer::Base.deliveries.last
		assert mail.subject, "Password reset."
		assert_not_equal @user.reset_digest, @user.reload.reset_digest
		assert_not @user.reset_sent_at.nil?
		assert_redirected_to login_url
		
		user = assigns(:user)

		#try to visit link with invalid token
		get edit_password_reset_path('invalid_token', email: user.email)
		assert_redirected_to root_url
		assert_not flash.empty?

		#try valid token but invalid email
		get edit_password_reset_url(user.password_reset_token, email: 'invalid_email')
		assert_redirected_to root_url
		assert_not flash.empty?

		#try valid token, valid email, but user not activated
		user.toggle!(:activated)
		assert_not user.activated?
		get edit_password_reset_url(user.password_reset_token, email: user.email)
		assert_redirected_to root_url
		assert_not flash.empty?
		user.toggle!(:activated)

		#try expired token
		user.update_attribute(:reset_sent_at, 121.minutes.ago)
		get edit_password_reset_url(user.password_reset_token, email: user.email)
		assert_redirected_to root_url
		assert_not flash.empty?
		user.update_attribute(:reset_sent_at, 1.minute.ago)

		#try valid token and email
		get edit_password_reset_url(user.password_reset_token, email: user.email)
		assert_template 'password_resets/edit'
		assert_select 'input[name=email][type=hidden][value=?]', user.email

		#try blank password
		patch password_reset_path(user.password_reset_token), email: user.email, user: {password: " ", password_confirmation: " "}
		assert_equal user.password_digest, user.reload.password_digest
		assert_template 'password_resets/edit'
		assert_select 'div[class=?]', 'alert alert-danger'
		assert_select 'div#error_explanation' do
			assert_select 'li', "Password can not be blank"
		end

		#try mismatched password
		patch password_reset_path(user.password_reset_token), email: user.email, user: {password: "123456", password_confirmation: "654321"}
		assert_equal user.password_digest, user.reload.password_digest
		assert_template 'password_resets/edit'
		assert_select 'div[class=?]', 'alert alert-danger'
		assert_select 'div#error_explanation'

		#try patching user password
		patch password_reset_path(user.password_reset_token), email: user.email, user: {password: "new_password", password_confirmation: "new_password"}
		#check for updated password
		assert_not_equal user.password_digest, user.reload.password_digest
		#check for logged in
		assert is_logged_in?
		#check for template users/show
		assert_redirected_to user 
		follow_redirect!
		assert_template 'users/show'
		assert_not flash.empty?

	end

end
