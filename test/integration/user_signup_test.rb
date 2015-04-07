require 'test_helper'

class UserSignupTest < ActionDispatch::IntegrationTest
  
  def setup 

    @invite = invitations(:one)
    ActionMailer::Base.deliveries.clear
  
  end

	test "invalid signup information" do

      get signup_path
      assert_template 'users/new'

      get signup_path(invite: @invite)
      assert_template 'users/new'

      #POST valid fields without invite attribute creates user that will NOT be activated
      assert_difference 'User.count', 1 do
        post users_path, user: { name: @invite.name, email: @invite.email, password: "123456", password_confirmation: "123456", playa_name: "Flirter1" }
      end
      assert_redirected_to root_url
      user = assigns(:user)
      assert_not user.nil?
      assert_not user.activated?
      assert_not is_logged_in?
      assert_not flash.empty?

      # invalid user information WITH invite attribute should render :new
  		assert_no_difference 'User.count' do
  			post users_path, invite: @invite.id, user: { name: @invite.name, email: @invite.email, password: "", password_confirmation: "123", playa_name: " " }
        # debugger
  		end
  		assert_template 'users/new'
      assert_not is_logged_in?
  		assert_select "div[id=?]", "error_explanation"
      assert_not assigns(:invite).nil?
      assert_select 'p.form-static-control', text: @invite.email
      assert_select 'input[type=?]', 'hidden', value: @invite.email
      assert_select 'input[id=?]', "user_name", value: @invite.name

      #POST with missing email attribute 
      assert_no_difference 'User.count' do
        post users_path, invite: @invite.id, user: { name: @invite.name, password: "123456", password_confirmation: "123456", playa_name: "Flirter1" }
        # debugger
      end
      assert_template 'users/new'
      assert_not is_logged_in?
      assert_select "div[id=?]", "error_explanation"
      
      assert_not assigns(:invite).nil?
      assert_select 'p.form-static-control', text: @invite.email
      assert_select 'input[type=?]', 'hidden', value: @invite.email
      assert_select 'input[id=?]', "user_name", value: @invite.name
  
  	end

  	test "valid signup information with invite" do
		  
      get signup_path(invite: @invite)

      assert_not assigns(:invite).nil?
      assert_select 'p.form-static-control', text: @invite.email
      assert_select 'input[type=?]', 'hidden', value: @invite.email
      assert_select 'input[id=?]', "user_name", value: @invite.name

  		assert_difference 'User.count', 1 do
  			post users_path, invite: @invite.id, user: { name: @invite.name, email: @invite.email, password: "123456", password_confirmation: "123456", playa_name: "Flirter1" }
  		end

      #do NOT send a aactivation email. Activation happens automatically
      assert_equal 0, ActionMailer::Base.deliveries.size
      user = assigns(:user)
      assert user.activated?

      follow_redirect!
      assert_template 'static_pages/home'
      assert_not flash.empty?
      assert is_logged_in?

  	end
  	

    test "valid signup information with incorrect invite" do
      
      wrong_invite = invitations(:one_1)
      
      get signup_path(invite: @invite)

      assert_not assigns(:invite).nil?
      assert_select 'p.form-static-control', text: @invite.email
      assert_select 'input[type=?]', 'hidden', value: @invite.email
      assert_select 'input[id=?]', "user_name", value: @invite.name

      assert_difference 'User.count', 1 do
        post users_path, invite: wrong_invite.id, user: { name: @invite.name, email: @invite.email, password: "123456", password_confirmation: "123456", playa_name: "Flirter1" }
      end

      #do NOT send an activation email. Activation happens automatically
      assert_equal 1, ActionMailer::Base.deliveries.size
      user = assigns(:user)
      assert_not user.activated?

      follow_redirect!
      assert_template 'static_pages/home'
      assert_not flash.empty?
      assert_not is_logged_in?

    end


    test "valid signup information without invite" do
      
      get signup_path

      assert assigns(:invite).nil?
      # assert_select 'p.form-static-control', text: ""
      assert_select 'input[type=?]', 'hidden', value: ""
      assert_select 'input[id=?]', "user_name", value: ""

      assert_difference 'User.count', 1 do
        post users_path, user: { name: @invite.name, email: @invite.email, password: "123456", password_confirmation: "123456", playa_name: "Flirter1" }
      end

      #do NOT send a aactivation email. Activation happens automatically
      assert_equal 1, ActionMailer::Base.deliveries.size
      user = assigns(:user)
      assert_not user.activated?

      follow_redirect!
      assert_template 'static_pages/home'
      assert_not flash.empty?
      assert_not is_logged_in?

      

    end


    test "signup from invitaiton" do

    end

end
