require 'test_helper'

class PaymentsControllerTest < ActionController::TestCase

  def setup

    @user = users(:archer)
    @admin = users(:brian)
    @event = events(:future)
    @payment = @user.payments.create(event: @event, payment_date: Date.today, amount: 100, description: "Some description")

  end



  test "redirect new on non-admin user" do
    get :new, user_id: @user
    assert_redirected_to login_path

    log_in_as @user
    get :new, user_id: @user
    assert_redirected_to root_url
  end

  test "redirect on new if user not found" do
    log_in_as @admin
    get :new, user_id: 1
    assert_redirected_to users_path
    assert_not flash.empty?
  end

  test "should get new" do
    log_in_as @admin
    get :new, user_id: @user
    assert_response :success
    assert_select 'title', full_title("New Payment")
    assert_equal @user, assigns(:user)
    assert_equal @event, assigns(:next_event)
    assert assigns(:payment).new_record?

  end


  test "redirect create on non-admin user" do

    assert_no_difference 'Payment.count' do
      post :create, user_id: @user, payment: {event_id: @event.id, payment_date: Date.today, amount: 100, description: "Some description"}
    end
    assert_redirected_to login_path

    log_in_as @user
    assert_no_difference 'Payment.count' do
      post :create, user_id: @user, payment: {event_id: @event.id, payment_date: Date.today, amount: 100, description: "Some description"}
    end

    assert_redirected_to root_url
  end

  test "redirect on create if user not found" do
    log_in_as @admin
    assert_no_difference 'Payment.count' do
      post :create, user_id: 1, payment: {event_id: @event.id, payment_date: Date.today, amount: 100, description: "Some description"}
    end
    assert_redirected_to users_path
    assert_not flash.empty?
  end

  test "should post create" do
    log_in_as @admin
    assert_difference 'Payment.count', 1 do
      post :create, user_id: @user, payment: {event_id: @event.id, payment_date: Date.today, amount: 100, description: "Some description"}

    end

    assert_response :redirect

    assert_equal @user, assigns(:user)
    assert_equal @event, assigns(:event)
    assert_not assigns(:payment).nil?

  end


#**************************************

  test "redirect edit on non-admin user" do

    get :edit, user_id: @user, id: @payment
    assert_redirected_to login_path

    log_in_as @user
    get :edit, user_id: @user, id: @payment
    assert_redirected_to root_url
  end

  test "redirect on edit if user not found" do
    log_in_as @admin
    get :edit, user_id: 1, id: @payment
    assert_redirected_to users_path
    assert_not flash.empty?
  end

  test "should get edit" do
    log_in_as @admin
    get :edit, user_id: @user, id: @payment
    assert_response :success

    assert_equal @user, assigns(:user)
    assert_equal @payment, assigns(:payment)

    assert_equal @payment, assigns(:payment)

  end


  test "redirect update on non-admin user" do

    patch :update, user_id: @user, id: @payment, payment: {event_id: @event.id, payment_date: Date.today, amount: 100, description: "Some description"}
    assert_redirected_to login_path

    log_in_as @user
    patch :update, user_id: @user, id: @payment, payment: {event_id: @event.id, payment_date: Date.today, amount: 100, description: "Some description"}

    assert_redirected_to root_url
  end

  test "redirect on update if user not found" do
    log_in_as @admin
    patch :update, user_id: 1, id: @payment, payment: {event_id: @event.id, payment_date: Date.today, amount: 100, description: "Some description"}

    assert_redirected_to users_path
    assert_not flash.empty?
  end

  test "should patch update" do
    log_in_as @admin
    patch :update, user_id: @user, id: @payment.id, payment: {event_id: @event.id, payment_date: Date.today, amount: 50, description: "Some description"}

    assert_response :redirect

    assert_equal @user, assigns(:user)
    assert_equal @payment, assigns(:payment)
    assert_equal 50, assigns(:payment).amount

  end
#**************************************


  test "redirect index on guest" do

    get :index, user_id: @user
    assert_redirected_to login_path
  end

  test "get index on correct user" do
    log_in_as @user
    get :index, user_id: @user
    #
    assert_response :success
    assert_select 'title', full_title("Camp Dues for #{@user.name}")
  end

  test "redirect get index on incorrect user" do
    log_in_as @user
    get :index, user_id: users(:kurt)
    assert_redirected_to root_path
  end

  test "redirect on index if user not found" do
    log_in_as @admin
    get :index, user_id: 1
    assert_redirected_to users_path
    assert_not flash.empty?
  end

  test "should get index" do
    log_in_as @admin
    get :index, user_id: @user
    assert_response :success
    assert_select 'title', full_title("Camp Dues for #{@user.name}")
    assert_equal @user, assigns(:user)
    assert_equal @user.payments.where(event: Event.next_event), assigns(:payments)

  end



  test "redirect destroy on non-admin user" do

    assert_no_difference 'Payment.count' do
      delete :destroy, user_id: @user, id: @payment
    end
    assert_redirected_to login_path

    log_in_as @user
    assert_no_difference 'Payment.count' do
      delete :destroy, user_id: @user, id: @payment
    end

    assert_redirected_to root_url
  end

  test "redirect on destroy if user not found" do
    log_in_as @admin
    assert_no_difference 'Payment.count' do
      delete :destroy, user_id: 1, id: @payment
    end
    assert_redirected_to users_path
    assert_not flash.empty?
  end

  test "should destroy payment" do
    log_in_as @admin
    assert_difference 'Payment.count', -1 do
      delete :destroy, user_id: @user, id: @payment
    end

    assert_response :redirect

    assert_equal @user, assigns(:user)
    assert_equal @event, assigns(:event)
    assert_equal @payment, assigns(:payment)

  end



end
