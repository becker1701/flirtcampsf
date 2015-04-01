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

		assert_redirected_to event_ticket_path(@event, assigns(:ticket))
		follow_redirect!
		assert_template 'tickets/show'

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

		@event.tickets << tickets(:one)
		@event.tickets << tickets(:two)
		assert_not @event.tickets.empty?

		log_in_as @user
		get event_tickets_path(@event)



		@event.tickets.each do |ticket|

			assert_select 'tr[id=?]', "ticket_id_#{ticket.id}" do 

				assert_select 'a[href=?]', edit_event_ticket_path(@event, @ticket, status: 2)
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

		# assert_select 'input[type=]', "submit", text: "Ticket Sold"



	end


end
