require 'test_helper'

class TicketVerificationTest < ActionDispatch::IntegrationTest

	def setup
		@event = events(:future)
		# @ticket = tickets(:one)
		# @ticket.verification_token = Ticket.new_token
	end

	test "ticket verification by email" do

		assert_difference 'Ticket.count', 1 do
			post event_tickets_path(@event), ticket: {name: "Some Person", email: "some@example.com", admission_qty: 1 }
		end

		assert assigns(:ticket)
		ticket = assigns(:ticket)

		#test for incorrect verification_token
		get edit_verify_ticket_path("asd"), email: ticket.email, ticket_id: ticket.id
		assert_redirected_to root_url
		assert_not ticket.reload.verified?
		assert ticket.reload.verified_at.nil?
		assert_not flash.empty?

		#test for incorrect email
		get edit_verify_ticket_path(ticket.verification_token), email: "incorrect email", ticket_id: ticket.id
		assert_redirected_to root_url
		assert_not ticket.reload.verified?
		assert ticket.reload.verified_at.nil?
		assert_not flash.empty?

		#test for incorrect ticket_id
		get edit_verify_ticket_path(ticket.verification_token), email: ticket.email, ticket_id: 9999
		assert_redirected_to root_url
		assert_not ticket.reload.verified?
		assert ticket.reload.verified_at.nil?
		assert_not flash.empty?

		#test valid path
		get edit_verify_ticket_path(ticket.verification_token), email: ticket.email, ticket_id: ticket.id
		assert_redirected_to event_ticket_path(@event, ticket)
		assert_not flash.empty?
		assert ticket.reload.verified?
		assert_not ticket.reload.verified_at.nil?

	end

end
