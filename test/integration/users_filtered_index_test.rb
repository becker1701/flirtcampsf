require 'test_helper'

class UsersFilteredIndexTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:brian)
		@user = users(:archer)
		@event = events(:future)
	end

=begin
	This integration test will test the User index page with certain search filters.
	Search filters will include:
		Attending this year
		Not attending this year
		Has Ticket
		Does not have ticket
		Yurt owner --  needs a seperate model
		Has Carpool available - Driving
		Earcly Arrival

	All users will be able to filter by all of these filters

=end

	test "user index links" do
		log_in_as users(:archer)
		get users_path
		assert_select 'a[href=?]', users_path
		assert_select 'a[href=?]', users_path(q: :attending_next_event), count: 1
		assert_select 'a[href=?]', users_path(q: :not_attending_next_event), count: 1
		assert_select 'a[href=?]', users_path(q: :not_responded_to_next_event), count: 1
		assert_select 'a[href=?]', users_path(q: :has_ticket_to_next_event), count: 1
		assert_select 'a[href=?]', users_path(q: :needs_ticket_to_next_event), count: 1
		assert_select 'a[href=?]', users_path(q: :driving_to_next_event), count: 1
		assert_select 'a[href=?]', users_path(q: :early_arrivals_next_event), count: 1


	end


	test "user filters by Attending This Year" do
		log_in_as @user
		get users_path(q: :attending_next_event)
		assert_template 'users/index'
		assert_select 'h2', text: "Members attending #{@event.year}"

		users = User.all

		users.each do |user|
			if user.activated? && user.next_event_intention
				if user.next_event_intention.going?
					assert_includes assigns(:users), user
				else
					assert_not_includes assigns(:users), user
				end
			elsif user.activated? && !user.next_event_intention
				assert_not_includes assigns(:users), user
			else
				assert_not_includes assigns(:users), user
			end
		end
	end


	test "user filters by Not Attending This Year" do
		log_in_as @user
		get users_path(q: :not_attending_next_event)
		assert_template 'users/index'
		assert_select 'h2', text: "Members not attending #{@event.year}"

		users = User.all

		users.each do |user|
			if user.activated? && user.next_event_intention
				if user.next_event_intention.going?
					assert_not_includes assigns(:users), user
				else
					assert_includes assigns(:users), user
				end
			elsif user.activated? && !user.next_event_intention
				assert_not_includes assigns(:users), user
			else
				assert_not_includes assigns(:users), user
			end
		end
	end

	test "user filters by Not Responded to This Year" do
		log_in_as @user
		get users_path(q: :not_responded_to_next_event)
		assert_template 'users/index'
		assert_select 'h2', text: "Members not responded to #{@event.year}"

		users = User.activated.not_responded_to_next_event.first(20)
		# puts "User count: #{users.count}"

		users.each do |user|

			if user.next_event_intention.nil?
				# binding.pry

				assert_includes assigns(:users), user
			else
				assert_not_includes assigns(:users), user
			end

		end
	end

	test "user filters by Has Ticket to This Year" do
		log_in_as @user
		get users_path(q: :has_ticket_to_next_event)
		assert_template 'users/index'
		assert_select 'h2', text: "Members who have tickets to #{@event.year}"

		users = User.activated.has_ticket_to_next_event
		# puts "User count: #{users.count}"

		users.each do |user|

			if user.next_event_intention.nil?
				# binding.pry

				assert_not_includes assigns(:users), user
			else
				if user.next_event_intention.status == "going_has_ticket" || user.next_event_intention.status == "not_going_has_ticket"
					assert_includes assigns(:users), user
				else
					assert_not_includes assigns(:users), user
				end
			end

		end
	end


	test "user filters by Needs Ticket to This Year" do
		log_in_as @user
		get users_path(q: :needs_ticket_to_next_event)
		assert_template 'users/index'
		assert_select 'h2', text: "Members who need tickets to #{@event.year}"

		users = User.activated.needs_ticket_to_next_event
		# puts "User count: #{users.count}"

		users.each do |user|

			if user.next_event_intention.nil?
				# binding.pry

				assert_not_includes assigns(:users), user
			else
				if user.next_event_intention.status == "going_needs_ticket"
					assert_includes assigns(:users), user
				else
					assert_not_includes assigns(:users), user
				end
			end

		end
	end


	test "user filters by Driving to This Year" do
		log_in_as @user
		get users_path(q: :driving_to_next_event)
		assert_template 'users/index'
		assert_select 'h2', text: "Members who are driving to #{@event.year}"

		users = User.activated.driving_to_next_event
		# puts "User count: #{users.count}"

		users.each do |user|

			if user.next_event_intention.nil?
				# binding.pry

				assert_not_includes assigns(:users), user
			else
				if user.next_event_intention.transportation == "driving"
					assert_includes assigns(:users), user
				else
					assert_not_includes assigns(:users), user
				end
			end

		end
	end


	test "user filters by Early Arrival to This Year" do
		log_in_as @user
		get users_path(q: :early_arrivals_next_event)
		assert_template 'users/index'
		assert_select 'h2', text: "Early Arrival Team for #{@event.year}"

		users = User.activated.early_arrivals_next_event
		# puts "User count: #{users.count}"

		users.each do |user|

			if user.next_event_early_arrival.nil?
				# binding.pry

				assert_not_includes assigns(:users), user
			else
				assert_equal @event, user.next_event_early_arrival.event
				assert_includes assigns(:users), user
			end

		end
	end



end
