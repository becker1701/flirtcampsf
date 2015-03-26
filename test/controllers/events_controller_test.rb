require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  
  def setup 
    @admin = users(:brian)
    @user = users(:archer)
    @future = events(:future)
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

end
