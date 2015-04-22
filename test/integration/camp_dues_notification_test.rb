require 'test_helper'

class CampDuesNotificationTest < ActionDispatch::IntegrationTest

	def setup 
		@admin = users(:brian)
		@user = users(:archer)
		@event = events(:future)

		p_1 = @user.payments.create(event: @event, payment_date: Date.today - 10.days, amount: 45)
		p_2 = @user.payments.create(event: @event, payment_date: Date.today - 5.days, amount: 75)

		p_3 = @user.payments.create(event: events(:past), payment_date: Date.today - 1.year, amount: 100)

		ActionMailer::Base.deliveries.clear

	end


	test "send camp dues notification" do
		log_in_as @admin

		get camp_dues_overview_event_path(@event)

		User.attending_next_event.each do |user|
			# puts "#{user.name}"
			assert_select 'a[href=?]', camp_dues_notification_user_path(user), count: 1
		end

		get camp_dues_notification_user_path(@user)
		assert_equal 1, ActionMailer::Base.deliveries.count


	end

end
