require 'test_helper'

class PaymentIndexTest < ActionDispatch::IntegrationTest

	def setup
	  	@event = events(:future)
	  	@user = users(:archer)
	  	@admin = users(:brian)
	end

	test "camp dues overview does not show for non admin" do
		log_in_as @user

		get user_payments_path(@user)

		assert_template 'payments/index'
		assert_select 'a[href=?]', camp_dues_overview_event_path(@event), count: 0
	end

	test "camp dues overview does show for admin" do
		log_in_as @admin

		get user_payments_path(@user)

		assert_template 'payments/index'
		assert_select 'a[href=?]', camp_dues_overview_event_path(@event), count: 1
	end


	test "wrong user redirected on camp dues overview" do
		log_in_as users(:elisabeth)

		get user_payments_path(@user)

		assert_redirected_to root_path
	end

end
