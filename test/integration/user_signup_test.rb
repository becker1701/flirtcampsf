require 'test_helper'

class UserSignupTest < ActionDispatch::IntegrationTest
  
  def setup 
    ActionMailer::Base.deliveries.clear
  end

	test "invalid signup information" do
		get signup_path
  		assert_no_difference 'User.count' do
  			post users_path, user: { name: " ", email:"invlid_email", password: "", password_confirmation: "123" }
  		end
  		assert_template 'users/new'
      assert_not is_logged_in?
  		assert_select "div[id=?]", "error_explanation"
  	end

  	test "valid signup information" do
		  get signup_path
  		assert_difference 'User.count', 1 do
  			post users_path, user: { name: "Valid Name", email:"valid_email@example.com", password: "123456", password_confirmation: "123456" }
  		end

      assert_equal 1, ActionMailer::Base.deliveries.size
      user = assigns(:user)
      assert_not user.activated?
      assert_not is_logged_in?

      #try to log in before activation
      log_in_as(user, remember_me: '0', password: "123456")
      assert_template 'sessions/new'
      assert_not is_logged_in?
      assert_not flash.empty?
      assert_select "a[href=?]", new_account_activation_path

      #try to activate with incorrect token
      get edit_account_activation_path('incorrect token', email: user.email)
      assert_redirected_to root_url
      assert_not is_logged_in?
      assert_not flash.empty?

      #try valid token and wrong email
      get edit_account_activation_path(user.activation_token, email: 'wrong')
      assert_redirected_to root_url
      assert_not is_logged_in?
      assert_not flash.empty?

      #try with correct activation token and email
  		get edit_account_activation_path(user.activation_token, email: user.email)
      assert user.reload.activated?
      follow_redirect!
      assert_template 'users/show'
      assert_not flash.empty?
      assert is_logged_in?

  	end
  	
end
