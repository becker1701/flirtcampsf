require 'test_helper'

class UserSignupTest < ActionDispatch::IntegrationTest
  
  def setup 

    @invite = invitations(:one)
    ActionMailer::Base.deliveries.clear
  
  end

	test "invalid signup information" do
	


  	# get signup_path
   #  assert_redirected_to root_url
   #  follow_redirect!
   #  assert_template "static_pages/home"

      get signup_path
      assert_redirected_to root_path

      get signup_path(invite: @invite)
      assert_template 'users/new'

      #POST without invite hidden field redirectes to rot_url
      assert_no_difference 'User.count' do
        post users_path, user: { name: " ", email:"invlid_email", password: "", password_confirmation: "123", playa_name: " " }
      end
      assert_redirected_to root_url
      assert_not is_logged_in?

      # invalid user information WITH invite attribute should render :new
  		assert_no_difference 'User.count' do
  			post users_path, invite: @invite.id, user: { name: " ", email:"invlid_email", password: "", password_confirmation: "123", playa_name: " " }
        # debugger
  		end
  		assert_template 'users/new'
      assert_not is_logged_in?
  		assert_select "div[id=?]", "error_explanation"
  
  	end

  	test "valid signup information" do
		  
      get signup_path(invite: @invite)

  		assert_difference 'User.count', 1 do
  			post users_path, invite: @invite.id, user: { name: "Valid Name", email:"valid_email@example.com", password: "123456", password_confirmation: "123456", playa_name: "Flirter1" }
  		end

      #do NOT send a aactivation email. Activation happens automatically
      assert_equal 0, ActionMailer::Base.deliveries.size
      user = assigns(:user)
      assert user.activated?

      #try to log in before activation
=begin
      log_in_as(user, remember_me: '0', password: "123456")
      assert_template 'sessions/new'
      assert_not is_logged_in?
      assert_not flash.empty?
      assert_select "a[href=?]", new_account_activation_path
=end


      #try to activate with incorrect token
=begin
      get edit_account_activation_path('incorrect token', email: user.email)
      assert_redirected_to root_url
      assert_not is_logged_in?
      assert_not flash.empty?
=end

      #try valid token and wrong email
=begin
      get edit_account_activation_path(user.activation_token, email: 'wrong')
      assert_redirected_to root_url
      assert_not is_logged_in?
      assert_not flash.empty?
=end

      #try with correct activation token and email

  		# get edit_account_activation_path(user.activation_token, email: user.email)
      # assert user.reload.activated?
      follow_redirect!
      assert_template 'static_pages/home'
      assert_not flash.empty?
      assert is_logged_in?



  	end
  	
end
