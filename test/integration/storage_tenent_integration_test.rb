require 'test_helper'

class StorageTenentIntegrationTest < ActionDispatch::IntegrationTest

	def setup 
		@admin = users(:brian)
		@user = users(:archer)

	end

	test "assign camp storage in user profile by admin" do
		log_in_as @admin

		intention = @user.next_event_intention
		intention.storage_tenent = false
		intention.camp_due_storage = 0.0
		intention.save!
		
		get user_path(@user)

		assert_not intention.storage_tenent?
		
		#test when storage_tenent is false

		assert_match "<strong>Yurt owner:</strong> Yes", response.body
		assert_match "<strong>Yurt Panel Size:</strong> 1", response.body
		assert_match "<strong>Yurt Storage Requested:</strong> Yes", response.body

		assert_select 'form[id=?]', "edit_intention_#{@user.next_event_intention.id}" do
			assert_select 'input[type=?]', "checkbox"
			assert_select 'input[checked=?]', "checked", count: 0
			assert_select 'input#intention_camp_due_storage[value=?]', "0.0", count: 1
		end

		#assign valid storage tenent info
		patch edit_storage_tenent_event_intention_path(intention.event, intention), intention: { storage_tenent: true, camp_due_storage: 75 }
		assert_redirected_to user_path(@user)

		intention = assigns(:intention)
		assert_equal @user.next_event_intention, intention

		assert_not flash.empty?
		assert intention.storage_tenent?
		assert_equal 75, intention.camp_due_storage.to_i
		
		follow_redirect!

		assert_select 'form[id=?]', "edit_intention_#{@user.next_event_intention.id}" do
			assert_select 'input[type=?]', "checkbox"
			assert_select 'input[checked=?]', "checked", count: 1
			assert_select 'input#intention_camp_due_storage[value=?]', "75.0", count: 1
		end



	end

	test "admin storage tenent returns proper event" do

		log_in_as @admin

		get events_path
		events = assigns(:events)

		events.each do |event|
			assert_select 'a[href=?]', event_storage_tenents_path(event)
		end

		event = events.first
		get event_storage_tenents_path(event)
		assert_template 'storage_tenents/index'

		assert_equal event, assigns(:event)

		intentions = event.intentions.where(yurt_owner: true)
		assert_equal intentions, assigns(:tenents)

	end

end
