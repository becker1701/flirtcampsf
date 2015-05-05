require 'test_helper'

class UserLoginTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:brian)
	end

	test "log in and out with valid information" do
	    
	    get login_path
	    assert_template 'sessions/new'
	    post login_path, { email: @user.email, password: 'password' }
	    assert_redirected_to root_url
	    follow_redirect!
	    assert_template 'static_pages/home'
	    assert is_logged_in?
# debugger
	    assert_not assigns(:intention).nil?
	    assert_select 'h1', text: @user.playa_name
	    assert_select "a[href=?]", login_path, count: 0
	    assert_select "a[href=?]", logout_path
	    assert_select "a[href=?]", user_path(@user)
	    delete logout_path
	    assert_redirected_to root_path
	    assert_not is_logged_in?
	    
	    #simulate user clicking LOGOUT on a second tab/window
	    delete logout_path

	    follow_redirect!
	    assert_template 'static_pages/home'
	    
	    assert assigns(:intention).nil?
	    assert_select "a[href=?]", new_member_app_path, count: 1
	    assert_select "a[href=?]", new_existing_member_request_path, count: 1
	    assert_select "a[href=?]", login_path, count: 1
	    assert_select "a[href=?]", signup_path, count: 0
	    assert_select "a[href=?]", logout_path, count: 0
	    assert_select "a[href=?]", user_path(@user), count: 0
	end 



  test "redirect to profile page if remembered" do
		get login_path
	    assert_template 'sessions/new'
	    post login_path, { email: @user.email, password: 'password' }
	    assert_redirected_to root_url

	    follow_redirect!
	    assert_template 'static_pages/home'
	    # get root_url
	    # assert_redirected_to @user
	    # follow_redirect!
	    # assert_template 'users/show'
  end


  test "remember me when logging in" do
  	log_in_as(@user, remember_me: '1')
	assert_equal assigns(:user).remember_token, cookies['remember_token']
  end

  test "do not remember me when logging in" do
  	log_in_as(@user, remember_me: '0')
  	assert_nil cookies['remember_token'] 
  end

  test "non logged in user is freindly forwarded on login" do
  	get edit_user_path(@user)
  	log_in_as @user
  	assert_redirected_to edit_user_path(@user)

  end

  test "user is freindly-forwarded after logging in" do
  	get edit_user_path(@user)
  	assert_redirected_to login_path
  	assert_equal session['forwarding_url'], edit_user_url(@user)
  	log_in_as @user
  	assert_redirected_to edit_user_path(@user)
  	assert session['forwarding_url'].nil?
  	log_out
  	log_in_as @user
  	assert_redirected_to root_url
  end

#BUGS=================================

	#flash message on invalid login persistes after a redirect
	test "flash message does not persist" do
		get login_path
		assert_template 'sessions/new'
		post login_path, {email: "", password: ""}
		assert_template 'sessions/new'
		assert_not flash.empty?
		get root_path
		assert flash.empty?
	end

end
