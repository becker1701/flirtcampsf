require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  
  def setup 
    @admin = users(:brian)
    @user = users(:archer)
    @future = events(:future)
  end

  test "params" do
    log_in_as @admin

    post :create, event: {
      year: "2014",
      start_date: Date.today - 100.days,
      end_date:  Date.today - 90.days,
      theme: "Past Event",
      camp_address: "9:00 & I",
      early_arrival_date: Date.today - 105.days,
      camp_dues: 100,
      camp_dues_food: 50
      }


      event = assigns(:event)
      assert_not event.nil?
      assert_equal "2014", event.year
      assert_equal Date.today - 100.days, event.start_date
      assert_equal Date.today - 90.days, event.end_date
      assert_equal "Past Event", event.theme
      assert_equal "9:00 & I", event.camp_address
      assert_equal Date.today - 105.days, event.early_arrival_date
      assert_equal 100, event.camp_dues
      assert_equal 50, event.camp_dues_food

  end

  test "should get new if admin" do
    log_in_as @admin
    get :new
    assert_response :success
    assert_template 'events/new'  
  end

  test "should get show if admin" do
    log_in_as @admin
    get :show, id: @future
    assert_response :success
    assert_template 'events/show'
  end

  test "should get edit if admin" do
    log_in_as @admin
    get :edit, id: @future
    assert_response :success
    assert_template 'events/edit'
    assert_equal @future, assigns(:event)
  end

  test "redirected if get new when not admin" do
    log_in_as @user
    get :new
    assert_response :redirect
    # assert_template 'static_pages/home'
  end

  test "redirected if get show when not admin" do
    log_in_as @user
    get :show, id: @future
    assert_response :redirect
    # assert_template 'static_pages/home'
  end

  test "redirected if get edit when not admin" do
    log_in_as @user
    get :edit, id: @future
    assert_response :redirect
    # assert_template 'static_pages/home'
  end

  test "render edit on invalid :update as admin" do
    log_in_as @admin
    patch :update, id: @future.id, event: {year: " "}
    assert_template 'events/edit'
  end

  test "save and redirect on valid :update as admin" do
    log_in_as @admin
    patch :update, id: @future.id, event: {year: "2014"}
    assert_redirected_to events_url
  end

  test "redirect to root :update as non admin" do
    patch :update, id: @future.id
    assert_redirected_to login_url
  end

  test "get index only for admin" do
    get :index
    assert_redirected_to login_path

    log_in_as @admin
    get :index
    assert_response :success
    assert_template 'events/index'
  end

  test "delete event only for admin" do
    delete :destroy, id: @future
    assert_redirected_to login_path

    log_in_as @admin
    delete :destroy, id: @future
    assert_redirected_to events_url
  end

  test "redirect on dues_overview when not admin" do
    get :camp_dues_overview, id: @future
    assert_redirected_to login_path

    log_in_as @user
    get :camp_dues_overview, id: @future
    assert_redirected_to root_path    
  end

  test "redirect to users path on camp_dues_overview when event is incorrect" do
    log_in_as @admin
    get :camp_dues_overview, id: 1
    assert_redirected_to users_path
  end

  test "success on dues_overview when admin" do
    log_in_as @admin
    get :camp_dues_overview, id: @future
    assert_response :success
    assert_equal @future, assigns(:event)
    assert_equal User.attending_next_event, assigns(:users)
    assert_select 'title', full_title("Camp Dues Overview")
  end

end
