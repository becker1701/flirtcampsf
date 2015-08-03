require 'test_helper'

class EarlyArrivalsControllerTest < ActionController::TestCase
  
	def setup 
		@user = users(:archer)
		@event = events(:future)
		@admin = users(:brian)
		@ea = early_arrivals(:ea_archer)
	end

	test "success on index when admin" do 
		log_in_as @admin
		get :index, event_id: @event.id
		assert_response :success
		assert_not_nil assigns(:early_arrivals)
		assert_not_nil assigns(:event)
		assert_select 'title', full_title("Early Arrivals")
	end

	test "redirect on index when not admin" do
		get :index, event_id: @event.id
		assert_nil assigns(:early_arrivals)
		assert_redirected_to login_path

		log_in_as @user
		get :index, event_id: @event.id
		assert_nil assigns(:early_arrivals)
		assert_redirected_to root_url
	end

	test "redirect on delete when not admin" do
		assert_no_difference 'EarlyArrival.count' do
			delete :destroy, event_id: @event.id, id: @ea
		end
		assert_redirected_to login_path

		log_in_as @user
		assert_no_difference 'EarlyArrival.count' do
			delete :destroy, event_id: @event.id, id: @ea
		end
		assert_redirected_to root_path		
	end

	test "success on delete when admin" do
		log_in_as @admin
		assert_difference 'EarlyArrival.count', -1 do
			delete :destroy, event_id: @event.id, id: @ea
		end
		assert_redirected_to @ea.user
	end

	# test "success on new when admin" do
	# 	log_in_as @admin
	# 	get :new, event_id: @event.id
	# 	assert_response :success
	# 	assert_select 'title', full_title("New EA Member")
	# end

	# test "redirect on new when not admin" do
	# 	get :new, event_id: @event.id
	# 	assert_redirected_to login_path

	# 	log_in_as @user
	# 	assert_not @user.admin?
	# 	get :new, event_id: @event.id
	# 	assert_redirected_to root_path
	# end

	test "valid success on create when admin" do
		log_in_as @admin
		assert_difference 'EarlyArrival.count', 1 do
			post :create, event_id: @event.id, early_arrival: { user_id: @user.id }
		end
		assert_equal @user, assigns(:user), "User assigned not equal"
		assert_equal @event, assigns(:event), "Event assigned not equal"
		assert_redirected_to user_path(assigns(:user))
		# assert_not flash.empty?

	end 

	test "redirect on create when not admin" do
		assert_no_difference 'EarlyArrival.count' do
			post :create, event_id: @event.id, early_arrival: { user_id: nil }
		end
		assert_redirected_to login_path

		log_in_as @user
		assert_not @user.admin?
		assert_no_difference 'EarlyArrival.count' do
			post :create, event_id: @event.id, early_arrival: { user_id: nil }
		end
		assert_redirected_to root_path
	end

	test "invalid user redirect to ea index" do
		log_in_as @admin
		assert_no_difference 'EarlyArrival.count' do
			post :create, event_id: @event.id, early_arrival: { user_id: nil }
		end
		assert_redirected_to event_early_arrivals_path(@event)
	end

	# test "invalid event redirect to eaindex" do
	# 	log_in_as @admin
	# 	assert_no_difference 'EarlyArrival.count' do
	# 		post :create, early_arrival: { user_id: @user.id }
	# 	end
	# 	assert_redirected_to event_early_arrivals_path(@event)
	# end

	test "redirect on edit when not admin" do
		log_in_as @user
		get :edit, event_id: @event, id: @ea
		assert_redirected_to root_path
	end

	test "redirect on update when not admin" do
		log_in_as @user

		patch :update, event_id: @event, id: @ea, early_arrival: { ea_date: @event.extended_date_range.second }
		assert_redirected_to root_path
		assert_not_equal @event.extended_date_range.second, @ea.reload.ea_date
	end


	test "success on edit when admin" do
		log_in_as @admin
		get :edit, event_id: @event, id: @ea
		assert_response :success
		assert_template 'early_arrivals/edit'
		assert_equal @event, assigns(:event)
		assert_equal @ea, assigns(:ea)
	end

	test "success on update when admin" do
		log_in_as @admin

		patch :update, event_id: @event, id: @ea, early_arrival: { ea_date: @event.extended_date_range.second }
		assert_redirected_to event_early_arrivals_path(@event)
		assert_equal @event.extended_date_range.second, @ea.reload.ea_date
		assert_equal @event, assigns(:event)
		assert_equal @ea, assigns(:ea)
	end


end
