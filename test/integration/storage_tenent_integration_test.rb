require 'test_helper'

class StorageTenentIntegrationTest < ActionDispatch::IntegrationTest

	def setup 
		@admin = users(:brian)
		@user = users(:archer)

	end

	test "assign camp storage in user profile by admin" do
		log_in_as @admin

		intention = @user.next_event_intention

		get user_path(@user)

		assert_not intention.storage_tenent?
		assert_select 'form[id=?]', "edit_intention_#{@user.next_event_intention.id}" 


	end

end
