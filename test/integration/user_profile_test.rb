require 'test_helper'

class UserProfileTest < ActionDispatch::IntegrationTest

	include MembershipApplicationsHelper

	def setup
		@admin = users(:brian)
		@user = users(:archer)
		@event = events(:future)
		@user.intentions.delete_all
	end

	test "redirect to root with Going With Ticket message" do
		get root_url
		log_in_as @user
		assert_redirected_to root_url
		follow_redirect!
		assert is_logged_in?
		intention = assigns(:intention)
		
		assert_not intention.persisted?

		assert_template partial: 'intentions/_change_status'
		assert_select 'a[href=?]', event_intentions_path(@event, status: :going_has_ticket)

		#user clicks status: 1. Create intention and reload page with intention fields
		assert_difference 'Intention.count', 1 do
			post event_intentions_path(@event), status: :going_has_ticket
		end

		assert_redirected_to edit_event_intention_path(@event, assigns(:intention))
	end



	test "redirect to root with Going Needs Ticket message" do
		get root_url
		log_in_as @user
		assert_redirected_to root_url
		follow_redirect!
		assert is_logged_in?
		intention = assigns(:intention)
		assert_select 'a[href=?]', event_intentions_path(@event, status: :going_needs_ticket)

		#user clicks status: 1. Create intention and reload page with intention fields
		assert_difference 'Intention.count', 1 do
			post event_intentions_path(@event), status: :going_needs_ticket
		end
		assert_redirected_to edit_event_intention_path(@event, assigns(:intention))
	end


	test "redirect to root with Not Going Has Ticket message" do
		get root_url
		log_in_as @user
		assert_redirected_to root_url
		follow_redirect!
		assert is_logged_in?
		intention = assigns(:intention)
		assert_select 'a[href=?]', event_intentions_path(@event, status: :not_going_has_ticket)

		#user clicks status: 1. Create intention and reload page with intention fields
		assert_difference 'Intention.count', 1 do
			post event_intentions_path(@event), status: :not_going_has_ticket
		end
		assert_redirected_to edit_event_intention_path(@event, assigns(:intention))
	end


	test "redirect to root with Not Going No Ticket message" do
		get root_url
		log_in_as @user
		assert_redirected_to root_url
		follow_redirect!
		assert is_logged_in?
		intention = assigns(:intention)
		assert_select 'a[href=?]', event_intentions_path(@event, status: :not_going_no_ticket)

		#user clicks status: 1. Create intention and reload page with intention fields
		assert_difference 'Intention.count', 1 do
			post event_intentions_path(@event), status: :not_going_no_ticket
		end
		assert_redirected_to edit_event_intention_path(@event, assigns(:intention))
	end


	test "user profile page" do
		
		get root_url
		log_in_as @user
		assert_redirected_to root_url
		follow_redirect!
		assert is_logged_in?
		assert_match display_name(@user), response.body

		assert_not assigns(:next_event).nil?

		assert_template 'static_pages/home', partial: 'intentions/change_status'

		assert_select 'div#camp_info' do
			assert_select 'strong', "Camp Info"
		end 

		assert_not assigns(:intention).nil?
		intention = assigns(:intention)


		#test for no next_event
		# assert_not assigns(:next_event).nil?

	end

	test "go to another users page and see intention status" do
		log_in_as @user

		#admin intention set in fixtures

		@event.intentions.create!(status: :going_needs_ticket, user: @user, logistics: "blah")
		get user_path(@admin)

		assert_equal @admin, assigns(:user)
		
		assert_template 'users/show'
		assert_match @admin.name, response.body
		assert_match "Lilly and Michelle", response.body

		assert_no_match "blah", response.body

		get root_url

		assert_template 'static_pages/home'
		assert_no_match @admin.name, response.body
		assert_no_match "Lilly and Michelle", response.body

		assert_match "blah", response.body

	end

end
