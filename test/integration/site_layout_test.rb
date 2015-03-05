require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:brian)
  end

  test "layout links" do
    #guest user, not signed in
  	get root_path
  	assert_template 'static_pages/home'
  	assert_select "a[href=?]", root_path, count: 2
  	assert_select "a[href=?]", about_path
  	assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", new_member_app_path
  	assert_select "a[href=?]", login_path
  	assert_select 'a[href=?]', "http://burningman.org/"
    get signup_path
  	assert_select "title", full_title("Sign Up")

    get login_path
    assert_select 'a[href=?]', signup_path
    assert_select 'a[href=?]', new_password_reset_path

    log_in_as @user
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", root_path, count: 2
    assert_select 'a[href=?]', users_path, text: "Members"
    assert_select 'a[href=?]', user_path(@user), text: "Profile"
    assert_select 'a[href=?]', edit_user_path(@user), text: "Settings"
    assert_select 'a[href=?]', login_path, count: 0
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select 'a[href=?]', "http://burningman.org/"
  end

end
