require 'test_helper'

class EventCreateTest < ActionDispatch::IntegrationTest
  
=begin
	This integration test will test the creation of teh Next Year of Burning Man, how it displays on the users home 
	page, and the options that will be included within the event listing on the user home page.

	1. To create a New Event, the Camp Organizer will be the only one who will be able to create an event.
		The event can not be deleted, only canceled for the camp
	2. Once the event is created:
		the camp organizer can update all fields in Event.
		The Event is displayed on the users home page 
	3. User Home Page:
		User will need to select what their intention is for the year
			I have a ticket and am going
			I want to go and NEED a ticket
			I am not going, but have a ticket to sell
			I am not going and do not have a ticket 
		That will set the intention that the user will be able to change at any point.
	4. If a user changes their intention and indicates they have a ticket, automatically send an email out to the folks
		without tickets that want to go that the tickets are for sale.	
=end

	def setup
		@admin = users(:brian)
		@user = users(:archer)
		@user.intentions.delete_all
		
	end

	test "event creation" do

		#test guest user can not create event
		get new_event_path
		assert_not is_logged_in?
		assert_redirected_to login_url
		assert_not flash.empty?

		log_in_as @user
		get new_event_path
		assert is_logged_in?
		assert_redirected_to root_url
		assert_not flash.empty?

		delete logout_path
		assert_not is_logged_in?

		log_in_as @admin
		assert is_logged_in?
		get events_path
		assert_template 'events/index'

		events = Event.all

		events.each do |event|
			assert_includes assigns(:events), event
		end
		# assert_equal Event.all, assigns(:events)
		events = assigns(:events)
		assert_equal 2, events.count

		assert_select 'a[href=?]', new_event_path, count: 1
		assert_select 'a[href=?]', users_path(format: "csv")

		events.each do |event|
			assert_select 'div[id=?]', "event_id_#{event.id}" do
				assert_match event.year, response.body
				assert_select 'a[href=?]', edit_event_path(event)
				assert_select 'a[href=?]', event_path(event), method: :delete, text: "Remove event"
				assert_select 'a[href=?]', food_restrictions_users_path(event, format: "csv"), count: 1
			end
		end

		get new_event_path
		assert_template 'events/new'

		#try to create invalid record - year blank
		assert_no_difference 'Event.count' do
			post events_path, event: {year: " ", start_date: nil, end_date: nil, theme: " ", camp_address: " ", early_arrival_date: nil}
		end
		assert_template 'events/new'
		assert_select 'div#error_explanation'

		#try valid event
		assert_difference 'Event.count', 1 do
			post events_path, event: {year: "2015", start_date: Date.today + 100.days, end_date: Date.today + 107.days, theme: " ", camp_address: " ", early_arrival_date: Date.today + 95.days}
		end

		event = assigns(:event)

		assert_redirected_to events_path
		assert_not flash.empty?

		delete logout_path

		#as a user, show the event information on my root page.
		log_in_as @user 
		get root_url

		# debugger
		assert_select 'h1', text: event.year

		assert_select 'a', "I am camping with Flirt Camp and I do have a ticket!"
		assert_select 'a', "I want to camp with Flirt Camp, but do not have a ticket :("
		assert_select 'a', "I am NOT camping with Flirt Camp, but do have ticket(s) for sale :)"
		assert_select 'a', "I will not be camping with Flirt Camp for this event..."

	end

	test "event update" do
		
		log_in_as @admin
		
		future = events(:future)
		future.update_attribute(:theme, " ")

		assert is_logged_in?
		get edit_event_path(future)
		
		assert_template 'events/edit'

		#try to update invalid record - year blank
		patch event_path(future), event: {year: " ", start_date: nil, end_date: nil, theme: " ", camp_address: " ", early_arrival_date: nil}
		assert_template 'events/edit'
		assert_select 'div#error_explanation'

		#try to update valid record 
		patch event_path(future), event: {year: future.year, theme: "Some Future Theme"}
		assert_equal "Some Future Theme", future.reload.theme

		assert_redirected_to events_path
		get root_url
		# follow_redirect!
		assert_select 'small', text: "Some Future Theme"
		
	end

	test "no next event" do
		Event.destroy_all
		# event = events(:future)
		# event.start_date = Date.today - 120.days
		# event.end_date = Date.today - 119.days
		log_in_as @user
		get root_url
		assert_match "No event scheduled", response.body

		#check the profiles of other members
		get user_path @admin
		assert_template 'users/show'
		

	end

	test "remove event" do
		log_in_as @user 
		assert_no_difference 'Event.count' do
			delete event_path(events(:future))
		end
		assert_not flash.nil?
		assert_redirected_to root_url

		log_in_as @admin

		assert_difference 'Event.count', -1 do
			delete event_path(events(:future))
			assert Intention.where(event: events(:future)).empty?
		end

		assert_redirected_to events_url
		follow_redirect!
		assert_equal 1, assigns(:events).count
		assert_includes assigns(:events), Event.first

	end

	test "events index" do
		get events_path
		assert_redirected_to login_path

		log_in_as @user
		get events_path
		assert_redirected_to root_url

		log_in_as @admin
		get events_path
		assert_template 'events/index'
		events = assigns(:events)
		assert_not_nil events

		events.each do |event|
			assert_select 'a[href=?]', event_activities_path(event)
			assert_select 'a[href=?]', event_early_arrivals_path(event), text: "EA Team"
			assert_select 'a[href=?]', '#', text: "Meal Menu"
			assert_select 'a[href=?]', event_path(event), text: "Remove event"

		end
		assert_select 'a[href=?]', new_event_path
	end
end
