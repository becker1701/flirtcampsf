require 'test_helper'

class ActivitiesCreateTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:archer)
		@admin = users(:admin)
		@event = events(:future)
		@creator = users(:brian)


	end


	test "add an activity" do
		
		get new_event_activity_path(@event)
		assert_redirected_to login_path

		log_in_as @user
		get root_url

		assert_select 'a[href=?]', event_activities_path(@event)

		get event_activities_path(@event)
		#activites index test...

		get new_event_activity_path(@event)

		assert_select 'h1', "Add an Activity"

				

	end

	test "edit links for creator and admin only" do

		# activity = activites(:one)
		log_in_as @user
		assert_not @user.admin?
		assert is_logged_in?
		#test index
		#logged in as non-admin, not the creator
		get event_activities_path(@event)
		activities = assigns(:activities)

		activities.each do |activity|
			if activity.user == @user
				assert_equal @user, activity.user
				assert_select 'a[href=?]', edit_event_activity_path(@event, activity), count: 1
				assert_select 'a[href=?]', event_activity_path(@event, activity), text: "Remove", count: 1
			else
				assert_not_equal @user, activity.user
				assert_select 'a[href=?]', edit_event_activity_path(@event, activity), count: 0
				assert_select 'a[href=?]', event_activity_path(@event, activity), text: "Remove", count: 0
			end	
		end

		#test show
		activity = activities(:one)
		get event_activity_path(@event, activity)
		assert_select 'a[href=?]', edit_event_activity_path(@event, activity), count: 0
		assert_select 'a[href=?]', event_activity_path(@event, activity), text: "Remove", count: 0


		log_in_as @creator
		@creator.toggle!(:admin)
		assert_not @creator.admin?
		#test index
		#logged in as non-admin, not the creator
		get event_activities_path(@event)
		activities = assigns(:activities)

		activities.each do |activity|
			if activity.user == @creator
				assert_equal @creator, activity.user
				assert_select 'a[href=?]', edit_event_activity_path(@event, activity), count: 1
				assert_select 'a[href=?]', event_activity_path(@event, activity), text: "Remove", count: 1
			else
				assert_not_equal @creator, activity.user
				assert_select 'a[href=?]', edit_event_activity_path(@event, activity), count: 0
				assert_select 'a[href=?]', event_activity_path(@event, activity), text: "Remove", count: 0
			end	
		end

		#test show
		activity = activities(:one)
		get event_activity_path(@event, activity)
		assert_equal activity.user, @creator
		assert_select 'a[href=?]', edit_event_activity_path(@event, activity), count: 1
		assert_select 'a[href=?]', event_activity_path(@event, activity), text: "Remove", count: 0


		log_in_as @admin
		assert @admin.admin?
		#logged in as admin, not the creator
		get event_activities_path(@event)
		activities = assigns(:activities)

		activities.each do |activity|
			# assert_not_equal @admin, activity.user
			assert_select 'a[href=?]', edit_event_activity_path(@event, activity), count: 1
			assert_select 'a[href=?]', event_activity_path(@event, activity), text: "Remove", count: 1
		end

		#test show
		activity = activities(:one)
		get event_activity_path(@event, activity)
		assert_select 'a[href=?]', edit_event_activity_path(@event, activity), count: 1
		assert_select 'a[href=?]', event_activity_path(@event, activity), text: "Remove", count: 0

		#redirects checked in controller test

	end

	test "activities index" do
		#describe the activities index page
		assert_equal 2, @event.activities.count

		log_in_as @user

		get event_activities_path(@event)
		activities = assigns(:activities)

		assert_not_nil activities

		activities.each do |activity|
			# debugger
			assert_match activity.user.playa_name, response.body
			# assert_select 'a[href=?]', edit_event_activity_path(@event, activity)
		end

		assert_select 'a[href=?]', new_event_activity_path(@event)
	end

end
