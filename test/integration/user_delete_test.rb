require 'test_helper'

class UserDeleteTest < ActionDispatch::IntegrationTest


	def setup
		@admin = users(:brian)
		@user = users(:archer)
		@event = events(:future)
		@user.payments.create!(event: @event, payment_date: Date.today - 5.days, amount: 100)
		@user.payments.create!(event: @event, payment_date: Date.today - 7.days, amount: 50)
	end

	test "return flash error when payments exist on user delete" do
		log_in_as @admin

		assert @user.payments.any?

		delete user_path(@user)

		# assert_response :redirect
		#
		assert_redirected_to users_path
		assert_equal "Cannot delete record because dependent payments exist", flash[:danger]
	end

	test "do not return flash error when payments do not exist on user delete" do
		log_in_as @admin

		@user.payments.destroy_all
		assert @user.payments.empty?

		delete user_path(@user)

		assert_redirected_to users_path
		assert_not flash[:danger].present?
	end



end
