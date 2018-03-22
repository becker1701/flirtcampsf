require 'test_helper'

class PaymentTest < ActiveSupport::TestCase

	def setup
		@user = users(:archer)
		@event = events(:future)

		@payment = @user.payments.build(event: @event, payment_date: Date.today - 10.days, amount: 50)
	end

	test "valid payment" do
		assert @payment.valid?
	end

	test "payments.for_next_event returns payments for next_event" do
		#
		payment_1 = @user.payments.create!(event: @event, payment_date: Date.today - 5.days, amount: 100)
		payment_2 = @user.payments.create!(event: @event, payment_date: Date.today - 10.days, amount: 50)
		payment_3 = @user.payments.create!(event: events(:past), payment_date: Date.today - 1.year, amount: 50)


		assert_equal 150, @user.payments.for_next_event.sum(:amount)
		assert_equal 2, @user.payments.for_next_event.count

		assert_includes @user.payments.for_next_event, payment_1
		assert_includes @user.payments.for_next_event, payment_2
		assert_not_includes @user.payments.for_next_event, payment_3
	end

	test "invalid without amount" do
		@payment.amount = nil
		assert_not @payment.valid?
	end

	test "invalid without payment_date" do
		@payment.payment_date = " "
		assert_not @payment.valid?
	end

	test "invalid without event" do
		@payment.event = nil
		assert_not @payment.valid?
	end

	test "invalid without user" do
		@payment.user = nil
		assert_not @payment.valid?
	end

end
