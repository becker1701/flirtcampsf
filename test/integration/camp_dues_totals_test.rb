require 'test_helper'

class CampDuesTotalsTest < ActionDispatch::IntegrationTest
	def setup
		@admin = users(:brian)
		@user = users(:archer)
		@other_user = users(:kurt)
		@event = events(:future)
	end

	test "camp dues totals" do
		log_in_as @admin

		@user.payments.create!(event: @event, payment_date: Date.today, amount: 100)

		users = User.attending_next_event

		total_camp_dues = 0
		total_payments = 0
		total_balance = 0

		users.each do |user|
			total_camp_dues = total_camp_dues + user.sum_camp_dues
			total_payments = total_payments + user.sum_next_event_payments
			total_balance = total_balance + user.next_event_camp_dues_balance
		end

		get camp_dues_overview_event_path(@event)
		assert_select 'span#camp_dues_total', text: "$#{total_camp_dues.to_i}"
		assert_select 'span#camp_payments_total', text: "$#{total_payments.to_i}"
		assert_select 'span#camp_balance_total', text: "$#{total_balance.to_i}"


	end

end
