require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
	def setup
		@user = users(:brian)
		@other_user = users(:archer)
    @admin = users(:admin)
    @invite = invitations(:for_archer)
	end

  test "get new if no invitation" do
    get :new
    assert_response :success
    assert assigns(:invite).nil?
  end

  test "get new and set invite if invite exists" do

    get :new, invite: @invite.id
    assert_response :success
    assert_not assigns(:invite).nil?
    assert_equal @other_user.email, assigns(:invite).email
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


  test "Intention deleted when user is deleted" do
    log_in_as @admin

    assert_not @user.intentions.empty?
    count = @user.intentions.count

    assert_difference 'Intention.count', -count do 
      delete :destroy, id: @user
    end
  end

  test "nullify activity user_id when user is deleted" do
    log_in_as @admin

    activity_1 = activities(:one)
    activity_2 = activities(:past_two)

    assert_not @user.activities.empty?
    activities = @user.activities
    assert_no_difference 'Activity.count' do 
      delete :destroy, id: @user
    end

    assert_nil activity_1.reload.user_id
    assert_nil activity_2.reload.user_id

  end

  test "delete user when payments present returns error" do

    log_in_as @admin

      @other_user.payments.create!(event: events(:future), payment_date: Date.today-5.days, amount: 100)
      @other_user.payments.create!(event: events(:future), payment_date: Date.today-3.days, amount: 75)

      assert @other_user.errors.empty?

      assert_no_difference 'User.count' do
        delete :destroy, id: @other_user
      end

      user = assigns(:user)
      assert_not user.errors.empty?
      assert_includes user.errors.full_messages, "Cannot delete record because dependent payments exist"

      user.payments.destroy_all

      assert user.payments.empty?

      assert_difference 'User.count', -1 do
        delete :destroy, id: @other_user
      end

  end

  test "redirect on camp_due_notifications if not admin" do
      
    ActionMailer::Base.deliveries.clear 

    assert_not is_logged_in?
    get :camp_dues_notification, id: @user
    assert_redirected_to login_url
    assert_equal 0, ActionMailer::Base.deliveries.count

    log_in_as @other_user
    assert_not @other_user.admin?
    get :camp_dues_notification, id: @other_user
    assert_redirected_to root_path
    assert_equal 0, ActionMailer::Base.deliveries.count
  end

  test "send camp_dues_notification when admin" do
    log_in_as @admin
    ActionMailer::Base.deliveries.clear

    get :camp_dues_notification, id: @other_user
    assert_equal @other_user, assigns(:user)
    assert_equal 1, ActionMailer::Base.deliveries.count
    assert_redirected_to camp_dues_overview_event_path(events(:future))
    assert_not flash.nil?
  end

  test "success on index with no next event" do
    log_in_as @admin
    Event.destroy_all
    get :index
    assert_response :success
    

  end

end
