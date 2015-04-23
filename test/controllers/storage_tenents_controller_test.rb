require 'test_helper'

class StorageTenentsControllerTest < ActionController::TestCase
  
	def setup
		@admin = users(:brian)
		@user = users(:archer)
		@event = events(:future)
	end

	test "redirected on index when not admin" do
		get :index, event_id: @event
	  	assert_redirected_to login_path

	  	log_in_as @user
	  	get :index, event_id: @event
	  	assert_redirected_to root_path
	end

	test "should get index" do
		log_in_as @admin
		get :index, event_id: @event
		assert_response :success
		assert_not assigns(:tenents).nil?
		assert_equal assigns(:tenents), Intention.for_next_event.where(yurt_owner: true)
	end

end
