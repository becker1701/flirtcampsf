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
		assert_redirected_to edit_intention_path(assigns(:intention))
	end

	test "update intention" do

	end
	
	test "get edit" do
		log_in_as @user
		@intention = @user.intentions.find_by(event: @event)
		get :edit, id: @intention
		assert_response :success
		assert_template "intentions/edit"
	end

	test "valid patch update" do
		log_in_as @user
		@intention = @user.intentions.find_by(event: @event)
		patch :update, id: @intention, intention: { status: :going_needs_ticket }
		assert_redirected_to root_url
		assert_response :redirect
	end

	test "invalid patch update" do
		log_in_as @user
		@intention = @user.intentions.find_by(event: @event)
		patch :update, id: @intention, intention: { status: nil }
		# debugger
		assert_template 'intentions/edit'
		# assert_response :
	end

end