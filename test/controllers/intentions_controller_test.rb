require 'test_helper'

class IntentionsControllerTest < ActionController::TestCase
  
	def setup
		@user = users(:archer)
		@other_user = users(:kurt)
		@event = events(:future)
		@intention = intentions(:for_archer)
	end

	# test "should get edit" do
	# 	get :edit
	# 	assert_response :success
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

	test "update intention" do
		skip
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