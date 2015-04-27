require 'test_helper'

class UserProfileTest < ActionDispatch::IntegrationTest

	include MembershipApplicationsHelper

	def setup
		@admin = users(:brian)
		@user = users(:archer)
		@event = events(:future)
		# @user.intentions.delete_all
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

			get user_path @user
			assert_template partial: 'intentions/_intention'
			assert_template partial: 'intentions/_status'
			if message == "going_has_ticket"

				assert_select 'h3', text: "Tickets:", count: 0
				assert_select 'h3', text: "Transportation:", count: 1
				assert_select 'h3', text: "Lodging:", count: 1
				assert_select 'h3', text: "Yurt Owner:", count: 1
				assert_select 'h3', text: "Meals:", count: 1
				assert_select 'h3', text: "Logistics:", count: 1
			elsif message == "going_needs_ticket"
				assert_select 'h3', text: "Tickets:", count: 0
				assert_select 'h3', text: "Transportation:", count: 1
				assert_select 'h3', text: "Lodging:", count: 1
				assert_select 'h3', text: "Yurt Owner:", count: 1
				assert_select 'h3', text: "Meals:", count: 1
				assert_select 'h3', text: "Logistics:", count: 1
			elsif message == "not_going_has_ticket"
				# debugger
				assert_select 'h3', text: "Tickets:", count: 0
				assert_select 'h3', text: "Transportation:", count: 0
				assert_select 'h3', text: "Lodging:", count: 0
				assert_select 'h3', text: "Yurt Owner:", count: 1
				assert_select 'h3', text: "Meals:", count: 0
				assert_select 'h3', text: "Logistics:", count: 0
			elsif message == "not_going_no_ticket"
				assert_select 'h3', text: "Tickets:", count: 0
				assert_select 'h3', text: "Transportation:", count: 0
				assert_select 'h3', text: "Lodging:", count: 0
				assert_select 'h3', text: "Yurt Owner:", count: 1
				assert_select 'h3', text: "Meals:", count: 0
				assert_select 'h3', text: "Logistics:", count: 0
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
		assert_select 'a[href=?]', event_tickets_path(@event)

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

		#check for no intention
		other_user = users(:kurt)
		intention = @event.intentions.find_by(user: other_user)
		intention.destroy


		get user_path(other_user)
		assert_response :success
		
		#admin intention set in fixtures

		intention = @event.intentions.create!(status: :going_needs_ticket, user: @user, logistics: "blah")

		# get user_path(@admin)

		Intention.statuses.each do |status, id|
			intention.status = status.to_sym
			intention.save
		# @event.intentions.create!(status: :going_needs_ticket, user: @user, logistics: "blah")
			get user_path(@admin)

			assert_equal @admin, assigns(:user)
		
			assert_template 'users/show'
			assert_match @admin.name, response.body
			assert_match "Lilly and Michelle", response.body
			assert_match @admin.email, response.body

			assert_no_match "blah", response.body

			get root_url

			assert_template 'static_pages/home'
			# assert_no_match @admin.name, response.body
			assert_no_match "Lilly and Michelle", response.body

			assert_no_match "blah", response.body
		end
	end

	test "phone number on user profile page" do
		log_in_as @admin
		get user_path @user

		assert @user.phone.blank?
		assert_select 'li[id=?]', "user-phone", count: 0

		@user.phone = "1231231234"
		@user.save
		assert @user.phone.present?
		get user_path(@user)
		assert_select 'li[id=?]', "user-phone", count: 1
		assert_match "(123) 123-1234", response.body

	end

	test "visit page of member who does not have next event intention" do
		Event.destroy_all
		@admin.intentions.destroy_all
		assert_empty @admin.intentions

		log_in_as @user
		get user_path(@admin)
		
		assert_response :success

	end

	test "activites count exists" do
		@event.intentions.create!(status: :going_needs_ticket, user: @user, logistics: "blah")
		log_in_as @user
		get root_path
		# debugger
		assert_select 'span[id=?]', "activity-count", text: "(12)"
	end

	test "camp-roster shows attending members and link" do
		
		log_in_as @user
		get root_url

		assert_equal 2, User.attending_next_event.count
		
		assert_select 'ul#camp-roster' do
			User.attending_next_event.each do |user|
				assert_select 'li[id=?]', "user_id_#{user.id}" do
					assert_select 'a[href=?]', user_path(user)
				end
			end
		end

		assert_select 'h3', text: "Camp Roster (#{User.attending_next_event.count})"
	end

	test "profile page success when no early arrival date" do
		
		log_in_as @user
		follow_redirect!

		assert_select 'span#camp_ea_date', "EA Date: #{ ea_date_presenter(@event) }"

		@event.early_arrival_date = nil
		@event.save

		get root_url
		
		assert_response :success
		assert_select 'span#camp_ea_date', "EA Date: TBD"

	end

	test "user next event intention.going? nil when no intention error" do
		log_in_as @admin

		user_w_no_intention = users(:aaa)
		assert user_w_no_intention.next_event_intention.nil?

		get user_path(user_w_no_intention)
		assert_response :success
	end

end
