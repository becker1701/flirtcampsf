require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
	def setup
		@user = users(:brian)
		@other_user = users(:archer)
    @admin = users(:admin)
	end

  test "get new" do
    get :new
    assert_response :success
  end

  test "redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end

  test "get index when logged in" do
    log_in_as @user
    get :index
    assert_response :success
    assert_select "title", full_title("All Camp Members")
  end

  test "redirect edit when not logged in" do
  	get :edit, id: @user
  	assert_not flash.empty?
  	assert_redirected_to login_url
  end

  test "redirect update when not logged in" do

  	patch :update, id: @user, user: {name: "Error Name", email: "error_email@example.com"}
  	assert_not flash.empty?
  	assert_redirected_to login_url
  end

  test "redirect edit if incorrect user" do
  	log_in_as @user
  	get :edit, id: @other_user
  	assert flash.empty?
  	assert_redirected_to root_url
  end

  test "redirect update if incorrect user" do
  	log_in_as @user
  	get :update, id: @other_user, user: {name: @other_user.name}
  	assert flash.empty?
  	assert_redirected_to root_url
  	@user.reload
  	assert_not_equal @user.name, @other_user.name
  end

  test "logged in user can not update admin attribute" do
    log_in_as @other_user
    assert_not @other_user.admin?
    patch :update, id: @other_user, user: {name: "Bill Braski", admin: true}
    @other_user.reload
    assert_equal @other_user.name, "Bill Braski"
    assert_not @other_user.admin?, "logged in user: admin should be false, but is #{@other_user.admin}"
  end

  test "redirect logged-in non-admin when deleteing user" do
    log_in_as @other_user
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to root_url
  end

  test "redirect guest when deleteing user" do
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to login_url
  end

  test "admin can delete user" do
    log_in_as @admin
    assert_difference 'User.count', -1 do
      delete :destroy, id: @user
    end
  end
end
