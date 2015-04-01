require 'test_helper'

class TicketsControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
  	@event = events(:future)
  	@ticket = tickets(:one)
  	@user = users(:archer)
  end

  test "success on new" do
  	get :new, event_id: @event.id
  	assert_response :success
  	
  	assert_not assigns(:event).nil?
  	assert_not assigns(:ticket).nil?
  	assert assigns(:ticket).new_record?

  	assert_select 'title', full_title("Sell Tickets")
  end


  test "success on new with user_id" do
  	get :new, event_id: @event.id, user_id: @user.id
  	assert_response :success
  	
  	assert_not assigns(:event).nil?
  	assert_not assigns(:ticket).nil?
  	assert_not assigns(:user).nil?
  	
  	assert assigns(:ticket).new_record?

  	assert_select 'title', full_title("Sell Tickets")
  end


  test "sucess on create" do

  	assert_difference 'Ticket.count', 1 do
  		post :create, event_id: @event.id, ticket: { name: "Brad Pitt", email: "brad@example.com", admission_qty: 1, parking_qty: 1, confirmation_number: "123456ABC" }
  	end
  	assert assigns(:event)
  	assert assigns(:ticket)
  	assert_redirected_to [@event, assigns(:ticket)]

  end


  test "render new on invalid create" do
  	assert_no_difference 'Ticket.count' do
  		post :create, event_id: @event.id, ticket: { name: "Brad Pitt", email: " ", admission_qty: 0, parking_qty: 0, confirmation_number: "123456ABC" }
  	end
  	assert assigns(:event)
  	assert assigns(:ticket)
  	assert_template 'tickets/new'
  end


  test "success on show" do
  	@event.tickets << @ticket
  	get :show, event_id: @event, id: @ticket

  	assert_response :success
  	assert assigns(:event)
  	assert assigns(:ticket)
  	assert_select 'title', full_title("Ticket for sale")
  end

  test "redirect when ticket returns nil" do

  	get :show, event_id: @event, id: @ticket

  	assert_response :redirect
  end

  test "redirected on index if not logged in" do
  	get :index, event_id: @event.id
  	assert_redirected_to login_path
  end

  test "success on index when logged in" do
  	log_in_as @user
  	get :index, event_id: @event.id
  	assert_response :success
  	assert_select 'title', full_title("Tickets for Sale")
  	assert assigns(:tickets)
  end



end
