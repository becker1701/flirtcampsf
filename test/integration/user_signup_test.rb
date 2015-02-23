require 'test_helper'

class UserSignupTest < ActionDispatch::IntegrationTest
  
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
  			post_via_redirect users_path, user: { name: "Valid Name", email:"valid_email@example.com", password: "123456", password_confirmation: "123456" }
  		end
  		assert_template 'users/show'
  		assert is_logged_in?
      assert_not flash.empty?
  	end
  	
end
