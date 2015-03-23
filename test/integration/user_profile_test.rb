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

		# assert_nil @user.intention
		assert_template partial: 'intentions/_change_status'
		assert_select 'a[href=?]', intentions_path(status: :going_has_ticket, event: @event.id)

		#user clicks status: 1. Create intention and reload page with intention fields
		assert_difference 'Intention.count', 1 do
			post intentions_path, { status: :going_has_ticket, event: @event.id }
		end

		# assert_redirected_to root_path
		# follow_redirect!
		# assert_template 'static_pages/home', partial: 'intentions/going_has_ticket'
		# assert_match "I will be attending #{@event.year}.", response.body
		# assert_match "I have secured tickets.", response.body

		assert_redirected_to edit_intention_path(assigns(:intention))


		
	end



	test "redirect to root with Going Needs Ticket message" do
		get root_url
		log_in_as @user
		assert_redirected_to root_url
		follow_redirect!
		assert is_logged_in?
		intention = assigns(:intention)

		# assert_nil @user.intention
		assert_select 'a[href=?]', intentions_path(status: :going_needs_ticket, event: @event.id)

		#user clicks status: 1. Create intention and reload page with intention fields
		assert_difference 'Intention.count', 1 do
			post intentions_path, { status: :going_needs_ticket, event: @event.id }
		end

		# assert_redirected_to root_path
		# follow_redirect!
		# assert_template 'static_pages/home', partial: 'intentions/going_needs_ticket'
		# assert_match "I will be attending #{@event.year}.", response.body
		# assert_match "I have NOT secured tickets.", response.body

		assert_redirected_to edit_intention_path(assigns(:intention))

	end


	test "redirect to root with Not Going Has Ticket message" do
		get root_url
		log_in_as @user
		assert_redirected_to root_url
		follow_redirect!
		assert is_logged_in?
		intention = assigns(:intention)

		# assert_nil @user.intention
		assert_select 'a[href=?]', intentions_path(status: :not_going_has_ticket, event: @event.id)

		#user clicks status: 1. Create intention and reload page with intention fields
		assert_difference 'Intention.count', 1 do
			post intentions_path, { status: :not_going_has_ticket, event: @event.id }
		end

		# assert_redirected_to root_path
		# follow_redirect!
		# assert_template 'static_pages/home', partial: 'intentions/not_going_has_ticket'
		# assert_match "I will NOT be attending #{@event.year}.", response.body
		# assert_match "I will be selling my secured tickets.", response.body

		assert_redirected_to edit_intention_path(assigns(:intention))

	end


	test "redirect to root with Not Going No Ticket message" do
		get root_url
		log_in_as @user
		assert_redirected_to root_url
		follow_redirect!
		assert is_logged_in?
		intention = assigns(:intention)

		# assert_nil @user.intention
		assert_select 'a[href=?]', intentions_path(status: :not_going_no_ticket, event: @event.id)

		#user clicks status: 1. Create intention and reload page with intention fields
		assert_difference 'Intention.count', 1 do
			post intentions_path, { status: :not_going_no_ticket, event: @event.id }
		end

		# assert_redirected_to root_path
		# follow_redirect!
		# assert_template 'static_pages/home', partial: 'intentions/not_going_no_ticket'
		# assert_match "I will NOT be attending #{@event.year}.", response.body
		# assert_match "I have NO secured tickets.", response.body

		assert_redirected_to edit_intention_path(assigns(:intention))

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
			# assert_match @event.camp_address, response.body
			# assert_match @event.early_arrival_date, response.body
		end 

		assert_not assigns(:intention).nil?
		intention = assigns(:intention)


		#test for no next_event
		# assert_not assigns(:next_event).nil?

	end

	test "go to another users page and see intention status" do
		log_in_as @user

		#admin intention set in fixtures

		@user.intentions.create!(status: :going_needs_ticket, event: @event, logistics: "blah")
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
