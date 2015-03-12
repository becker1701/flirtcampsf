require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:archer)
    @admin = users(:brian)
    @invite = invitations(:one)
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
    assert_select "a[href=?]", new_invitation_path, count: 0
  	assert_select 'a[href=?]', "http://burningman.org/"
    get signup_path(invite: @invite)
  	assert_select "title", full_title("Sign Up")

    get login_path
    assert_select 'a[href=?]', signup_path
    assert_select 'a[href=?]', new_password_reset_path

    log_in_as @user
    assert_redirected_to root_url
    follow_redirect!
    assert_template 'static_pages/home'
    assert_select "a[href=?]", new_invitation_path, count: 0
    assert_select "a[href=?]", root_path, count: 2
    assert_select 'a[href=?]', users_path, text: "Members"
    assert_select 'a[href=?]', user_path(@user), text: "Profile"
    assert_select 'a[href=?]', edit_user_path(@user), text: "Settings"
    assert_select 'a[href=?]', login_path, count: 0
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select 'a[href=?]', "http://burningman.org/"

    log_out

    log_in_as @admin
    get root_path
    assert_select "a[href=?]", new_invitation_path, count: 1
    assert_select "a[href=?]", membership_applications_path, count: 1
    assert_select "span.badge"
    assert_select "a[href=?]", new_event_path, count: 1

  end

  test "edit event link" do
    #show edit event only if there is an upcoming event listed
    @future = events(:future)

    assert @future, Event.next_event

    log_in_as @admin
    get root_url

    assert_select 'a[href=?]', edit_event_path(@future)

    delete logout_path

    log_in_as @user
    get root_url
  
    assert_select 'a[href=?]', edit_event_path(@future), count: 0
  
  end

end
