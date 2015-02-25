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
  	assert_select "a[href=?]", help_path
  	assert_select "a[href=?]", notes_path, count: 0
  	assert_select "a[href=?]", terms_of_use_path
  	assert_select "a[href=?]", signup_path
  	assert_select 'a[href=?]', "http://news.railstutorial.org/"
    get signup_path
  	assert_select "title", full_title("Sign Up")

    log_in_as @user
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select 'a[href=?]', users_path, text: "Users"
    assert_select 'a[href=?]', user_path(@user), text: "Profile"
    assert_select 'a[href=?]', edit_user_path(@user), text: "Settings"

    assert_select "a[href=?]", notes_path, count: 0
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", terms_of_use_path
    assert_select 'a[href=?]', "http://news.railstutorial.org/"
  end

end
