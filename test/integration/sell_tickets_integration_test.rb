require 'test_helper'

class SellTicketsIntegrationTest < ActionDispatch::IntegrationTest

	def setup
		@event = events(:future)
		@ticket = tickets(:one)
		@user = users(:archer)
	end

	test "guest sells tickets through root_path" do
		
		get root_path
		assert_select 'a[href=?]', new_event_ticket_path(@event)

		get new_event_ticket_path(@event)
		assert_template 'tickets/new'

		assert_select 'input[id=?]', "ticket_name"
		assert_select 'input[id=?]', "ticket_email"
		#test invalid ticket
		assert_no_difference 'Ticket.count' do
			post event_tickets_path(@event), ticket: { name: "Brad Pitt", email: " ", admission_qty: 0, parking_qty: 0, confirmation_number: "123456ABC" }
		end

		assert_template 'tickets/new'
		assert_select "div[id=?]", "error_explanation"

		#test valid ticket
		assert_difference 'Ticket.count', 1 do
			post event_tickets_path(@event), ticket: { name: "Brad Pitt", email: "brad@exmaple.com", admission_qty: 1, parking_qty: 0, confirmation_number: "123456ABC" }
		end		

		assert_redirected_to root_path #event_ticket_path(@event, assigns(:ticket))
		assert_not flash.empty?

		# follow_redirect!
		# assert_template 'tickets/show'

	end

	test "user sells ticket" do
		# debugger
		log_in_as @user

		get new_event_ticket_path(@event, user_id: @user.id)
		assert_template 'tickets/new'

		assert_match @user.name, response.body
		assert_match @user.email, response.body

	end

	test "redirect on show if ticket is nil" do
		
		@event.tickets.destroy_all

		get event_ticket_path(@event, @ticket)
		assert_response :redirect
		

	end

	test "ticket sales index" do

		get event_tickets_path(@event)
		assert_redirected_to login_path

		# @event.tickets << tickets(:one)
		# @event.tickets << tickets(:two)
		assert_not @event.tickets.empty?

		log_in_as @user
		get event_tickets_path(@event)



		@event.tickets.each do |ticket|
			# debugger
			if ticket.verified?
				assert_select 'tr[id=?]', "ticket_id_#{ticket.id}" do 

					assert_select 'a[href=?]', edit_event_ticket_path(@event, ticket, status: :sold)
				end 
			else
				assert_select 'tr[id=?]', "ticket_id_#{ticket.id}", false
			end
		end
		assert_select 'a[href=?]', new_event_ticket_path(@event, user_id: @user.id)


	end

	test "tickets when next_event is nil" do
		@event = nil

		get root_path
		assert_select 'a', text: "Sell your tickets", count: 0

	end

	test "user updates ticket status" do
		
		log_in_as @user
		get event_tickets_path(@event)

		ticket = tickets(:one)

		assert_not ticket.sold?

		get edit_event_ticket_path(@event, ticket, status: :sold)

		assert ticket.reload.sold?

		assert_redirected_to event_tickets_path(@event)
		follow_redirect!

		assert_select 'tr[id=?]', "ticket_id_#{ticket.id}" do
			assert_select 'a[href=?]', edit_event_ticket_path(@event, ticket, status: :sold), false
		end

	end

	test "delete ticket for admin only" do
		log_in_as @user
		get event_tickets_path(@event)

		@event.tickets.each do |ticket|
			assert_select 'tr[id=?]', "ticket_id_#{@ticket.id}" do
				assert_select 'a', { text: "Remove", count: 0 }
			end
		end

		log_in_as users(:admin)
		get event_tickets_path(@event)

		@event.tickets.each do |ticket|
			assert_select 'tr[id=?]', "ticket_id_#{@ticket.id}" do
				assert_select 'a', { text: "Remove", count: 1 }
			end
		end

	end

	test "guest user ticket email verification" do
		get new_event_ticket_path(@event)
		assert_not is_logged_in?

		ActionMailer::Base.deliveries.clear

		assert_difference 'Ticket.count', 1 do
			post event_tickets_path(@event), ticket: {name: "Some Person", email: "some@example.com", admission_qty: 1 }
		end

		assert assigns(:ticket)
		ticket = assigns(:ticket)

		assert_not ticket.verification_token.nil?
		assert_not ticket.verification_digest.nil?
		assert_not ticket.verified?
		assert ticket.verified_at.nil?

		assert_equal 1, ActionMailer::Base.deliveries.count

		assert_redirected_to root_path
		assert_not flash.empty?

	end

	test "logged in user ticket verification" do
		
		log_in_as @user 
		get new_event_ticket_path(@event)
		assert is_logged_in?

		ActionMailer::Base.deliveries.clear

		assert_difference 'Ticket.count', 1 do
			post event_tickets_path(@event), ticket: {name: "Some Person", email: "some@example.com", admission_qty: 1 }
		end

		assert assigns(:ticket)
		ticket = assigns(:ticket)

		assert ticket.verified?
		assert_not ticket.verified_at.nil?

		assert_equal 0, ActionMailer::Base.deliveries.count

		assert_redirected_to event_ticket_path(@event, ticket)
		assert_not flash.empty?
	end


	test "index only shows verified tickets for non admin" do
		log_in_as @user
		get event_tickets_path(@event)

		assert_not assigns(:tickets).empty?
		tickets = assigns(:tickets)
		assert_equal 2, tickets.size

		tickets.each do |ticket|
			assert ticket.verified?
		end
	end

	test "index shows all tickets for admin" do
		log_in_as users(:admin)
		get event_tickets_path(@event)

		assert_not assigns(:tickets).empty?
		tickets = assigns(:tickets)
		assert_equal 3, tickets.size
	end

end
