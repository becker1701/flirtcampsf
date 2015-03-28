require 'test_helper'

class UserProfileTest < ActionDispatch::IntegrationTest

	include MembershipApplicationsHelper

	def setup
		@admin = users(:brian)
		@user = users(:archer)
		@event = events(:future)
		@user.intentions.delete_all
	end

	test "redirect new intention to root with status message" do
		Intention.statuses.map do |message, id|
			
			@user.intentions.destroy_all
			@user.reload

			log_in_as @user
			get root_url

			intention = assigns(:intention)
			assert_not intention.nil?
			assert intention.new_record?
			
			assert_template partial: 'intentions/_change_status'

			assert_select 'a[href=?]', event_intentions_path(@event, status: message)
			assert_difference 'Intention.count', 1 do
				post event_intentions_path(@event), status: message
			end
			if message == "not_going_no_ticket"
				assert_redirected_to root_url
			else
				assert_redirected_to edit_event_intention_path(@event, assigns(:intention))
			end
		end
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

		assert_no_match "blah", response.body

	end

	test "visit page of member who does not have next event intention" do
		Event.destroy_all
		@admin.intentions.destroy_all
		assert_empty @admin.intentions

		log_in_as @user
		get user_path(@admin)
		
		assert_response :success

	end

end
