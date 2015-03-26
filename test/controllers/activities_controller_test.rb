require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase

  # guest:
  # -index: can view
  # -new: redirect to loging
  # -create: rediect to login
  # -show: can view
  # -edit: redirect to login
  # -update: redirect to login
  # -delete: redirect to login

  # member:
  # -index: can view
  # -new: get :new
  # -create: post :create
  # -show: get :show
  # -edit: get :edit
  # -update: patch :update
  # -delete: delete :destroy

  # admin:
  # -index: can view
  # -new: get :new
  # -create: post :create
  # -show: get :show
  # -edit: get :edit
  # -update: patch :update
  # -delete: delete :destroy

  setup do
    @activity = activities(:one) #user is Brian
    @creator = users(:brian)
    @admin = users(:admin)
    @user = users(:archer)
    @event = events(:future)

    @activity.event = @event
  end



  test "should get index" do
    get :index, event_id: @activity.event_id
    assert_response :success
    assert_not_nil assigns(:activities)
  end

  test "redirect guest on new activity" do
    get :new, event_id: @activity.event_id
    assert_redirected_to login_path
  end

  test "succces for logged in user on get new" do
    log_in_as @user
    get :new, event_id: @activity.event_id
    assert_response :success
  end

  test "redirect guest on create activity" do
    assert_no_difference('Activity.count') do
      post :create, event_id: @event.id, activity: { day: @activity.day, description: @activity.description, publish: @activity.publish, time: @activity.time, title: @activity.title, user_id: @creator.id }
    end
    assert_redirected_to login_path
  end 

  test "should create activity" do
    log_in_as @creator
    assert_difference('Activity.count', 1) do
      post :create, event_id: @event.id, activity: { day: @activity.day, description: @activity.description, publish: @activity.publish, time: @activity.time, title: @activity.title, user_id: @creator.id }
    end
    activity = assigns(:activity)
    assert_equal @creator.id, activity.reload.user_id
    assert_redirected_to event_activities_path(activity.event)

  end

  test "should show activity" do
    get :show, event_id: @event.id, id: @activity
    assert_response :success
  end

  test "redirect guest on edit activity" do
    get :edit, event_id: @event.id, id: @activity
    assert_redirected_to login_path
  end

  test "redirect wrong user on edit activity" do
    log_in_as @user
    get :edit, event_id: @event.id, id: @activity
    assert_redirected_to event_activities_path(@event)
  end

  test "redirect wrong user on update activity" do
    log_in_as @user
    patch :update, event_id: @event.id, id: @activity, activity: { day: @activity.day, description: "blah1", publish: @activity.publish, time: @activity.time, title: @activity.title }
    activity = assigns(:activity)
    assert_not_equal "blah1", activity.description
    assert_redirected_to event_activities_path(@event)
  end


  test "should get edit" do
    log_in_as @creator
    get :edit, event_id: @event.id, id: @activity
    assert_response :success
  end

  test "admin should get edit" do
    log_in_as @admin
    get :edit, event_id: @event.id, id: @activity
    assert_response :success

  end

  test "admin should update activity" do
    # @activity.user = @user
    log_in_as @admin

    patch :update, event_id: @event.id, id: @activity, activity: { day: @activity.day, description: "blah", publish: @activity.publish, time: @activity.time, title: @activity.title }
    
    activity = assigns(:activity)
    assert_equal @activity.user_id, activity.user_id
    assert_equal "blah", activity.description
    assert_redirected_to event_activities_path(@activity.event)
  end

  test "redirect guest on update activity" do
    patch :update, event_id: @event.id, id: @activity, activity: { day: @activity.day, description: @activity.description, publish: @activity.publish, time: @activity.time, title: @activity.title }
    assert_redirected_to login_path
  end

  test "should update activity" do
    log_in_as @user
    patch :update, event_id: @event.id, id: @activity, activity: { day: @activity.day, description: @activity.description, publish: @activity.publish, time: @activity.time, title: @activity.title }
    assert_redirected_to event_activities_path(@activity.event)
  end

  test "redirect guest on destroy activity" do
    assert_no_difference('Activity.count') do
      delete :destroy, event_id: @event.id, id: @activity
    end
    assert_redirected_to login_path
  end

  test "redirect if wrong user on delete activity" do
    log_in_as @user
    assert_not_equal @activity.user, @user
    
    assert_no_difference('Activity.count') do
      delete :destroy, event_id: @event.id, id: @activity
    end

    assert_redirected_to event_activities_path(@event)
  end

  test "admin success on delete activity" do
    # @activity.user = @user
    log_in_as @admin
    assert_not_equal @activity.user, @admin 

    assert_difference('Activity.count', -1) do
      delete :destroy, event_id: @event, id: @activity
    end

    assert_redirected_to event_activities_path(@event)
  end

  test "should destroy activity" do
    log_in_as @creator
    
    assert_difference('Activity.count', -1) do
      delete :destroy, event_id: @event.id, id: @activity
    end

    assert_redirected_to event_activities_path(@activity.event)
  end
end
