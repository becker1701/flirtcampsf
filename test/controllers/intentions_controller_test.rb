require 'test_helper'

class IntentionsControllerTest < ActionController::TestCase
  
	def setup
		@user = users(:archer)
		@other_user = users(:kurt)
		@event = events(:future)
		@intention = intentions(:for_archer)
	end

	# test "params" do

	# 	user = users(:aaa)
	# 	log_in_as user

	# 	assert_difference 'Intention.count', 1 do
	# 		post :create, event_id: @event.id, intention: { status: 1, user: user }
	# 	end
	# 	intention = assigns(:intention)
	# 	assert_not intention.nil?

	# 	binding.pry

	# 	patch :update, event_id: @event.id, id: intention, intention: {
	# 		arrival_date: Date.today + 120.days,
	# 		departure_date: Date.today + 125.days,
	# 		transportation: 1,
	# 		seats_available: 1,
	# 		lodging: 1,
	# 		yurt_owner: true,
	# 		yurt_storage: true,
	# 		yurt_panel_size: 1,
	# 		yurt_user: "Lilly and Michelle",
	# 		opt_in_meals: true,
	# 		food_restrictions: "none",
	# 		logistics: "I need a few bins transported",
	# 		tickets_for_sale: 1,
	# 		storage_bikes: 1,
	# 		logistics_bike: 2,
	# 		logistics_bins: 2,
	# 		lodging_num_occupants: 2,
	# 		shipping_yurt: false,
	# 		storage_tenent: true,
	# 		camp_due_storage: 75 }

	# 		intention = assigns(:intention)
	# 		assert_not intention.nil?

	# 		assert_equal user.id, intention.user_id
	# 		assert_equal @event.id, intention.event_id
	# 		# binding.pry
	# 		assert_equal 1, intention.status
	# 		assert_equal Date.today + 120.days, intention.arrival_date
	# 		assert_equal Date.today + 125.days, intention.departure_date
	# 		assert_equal 1, intention.transportation
	# 		assert_equal 1, intention.seats_available
	# 		assert_equal 1, intention.lodging
	# 		assert_equal true, intention.yurt_owner
	# 		assert_equal true, intention.yurt_storage
	# 		assert_equal 1, intention.yurt_panel_size
	# 		assert_equal "Lilly and Michelle", intention.yurt_user
	# 		assert_equal true, intention.opt_in_meals
	# 		assert_equal "none", intention.food_restrictions
	# 		assert_equal "I need a few bins transported", intention.logistics
	# 		assert_equal 1, intention.tickets_for_sale
	# 		assert_equal 1, intention.storage_bikes
	# 		assert_equal 2, intention.logistics_bike
	# 		assert_equal 2, intention.logistics_bins
	# 		assert_equal 2, intention.lodging_num_occupants
	# 		assert_equal false, intention.shipping_yurt
	# 		assert_equal true, intention.storage_tenent
	# 		assert_equal 75, intention.camp_due_storage



	# end

	test "redirect guest on create" do
		assert_no_difference 'Intention.count' do
			post :create, event_id: @event.id, status: :going_has_ticket
		end
		assert_redirected_to login_path
	end

	test "should create intention" do
		log_in_as @user
		assert_difference 'Intention.count', 1 do
			# debugger
			post :create, event_id: @event.id, status: :going_has_ticket
		end
		intention = assigns(:intention)
		assert_not_nil intention
		assert_redirected_to edit_event_intention_path(@event, intention)
	end

	test "correct user on update" do
		log_in_as @user
		existing_status = @intention.status
		patch :update, event_id: @event.id, id: @intention, intention: { status: :not_going_no_ticket}
		assert_not_equal existing_status, @intention.reload.status
		assert_redirected_to root_path
	end
	
	test "redirect incorrect user on edit" do
		# @intention = @event.intentions.find_by(user: @user)
		get :edit, event_id: @event.id, id: @intention
		assert_redirected_to login_path

		log_in_as @other_user
		get :edit, event_id: @event.id, id: @intention
		assert_redirected_to root_url
	end

	test "get edit" do
		log_in_as @user
		get :edit, event_id: @event.id, id: @intention
		assert_response :success
		assert_template "intentions/edit"
	end

	test "redirect incorrect user on update" do
		existing_status = @intention.status
		patch :update, event_id: @event.id, id: @intention, intention: { status: :not_going_no_ticket}
		assert_equal existing_status, @intention.reload.status
		assert_redirected_to login_path

		log_in_as @other_user
		assert_not_equal @intention.user, @other_user
		patch :update, event_id: @event.id, id: @intention, intention: { status: :not_going_no_ticket}
		assert_equal existing_status, @intention.reload.status
		assert_redirected_to root_url
	end

	test "valid patch update" do
		log_in_as @user
		assert_equal @intention.user, @user
		existing_status = @intention.status
		# @intention = @user.intentions.find_by(event: @event)
		patch :update, event_id: @event.id, id: @intention, intention: { status: :not_going_no_ticket }
		assert_not_equal existing_status, @intention.reload
		assert_redirected_to root_url
	end

	test "invalid patch update" do
		log_in_as @user
		# @intention = @user.intentions.find_by(event: @event)
		patch :update, event_id: @event.id, id: @intention, intention: { status: nil }
		# debugger
		assert_template 'intentions/edit'
		# assert_response :
	end

end