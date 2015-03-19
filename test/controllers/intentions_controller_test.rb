require 'test_helper'

class IntentionsControllerTest < ActionController::TestCase
  
	def setup
		@user = users(:archer)
		@event = events(:future)
	end

	# test "should get edit" do
	# 	get :edit
	# 	assert_response :success
	# end

	test "should create intention" do
		log_in_as @user
		assert_difference 'Intention.count', 1 do
			post :create, { status: :going_has_ticket, event: @event }
		end
		assert_redirected_to root_url
	end

	test "update intention" do

	end
	# test "should get show" do
	# 	get :show
	# 	assert_response :success
	# end

end