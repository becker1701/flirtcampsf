require 'test_helper'

class ExistingMemberRequestTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:brian)
		@user = users(:archer)
		ActionMailer::Base.deliveries.clear
	end

	# new members will visit flirt camp website and click on 'New Member App' button
	# They will be redirected to page 1 of the 'New Member App' with all of the logistics and agreements.
	# they will then fill in their contact info
	# then they will answer questions about why they want to be in Flirt Camp
	# Question regarding how many years they have been going to BM, yada, yada
	test "existing member request funtionality" do
		
		

		get new_existing_member_request_path
		assert_not is_logged_in?
		assert_template 'existing_member_requests/new'
		assert_select 'h1', text: "Flirt Camp Existing Member Request"

		assert_not is_logged_in?

		#post app with invalid fields
		assert_no_difference 'MembershipApplication.count' do
			# debugger
			post existing_member_requests_path, membership_application: { name: " ", playa_name: "test", email: " " }
		end

		assert_template 'existing_member_requests/new'
		assert_select 'div#error_explanation'	
		assert flash.empty?
		assert_select 'input[value=?]', "test"
		assert_equal 0, ActionMailer::Base.deliveries.count

		#post app with valid fields without playa name
		assert_difference 'MembershipApplication.count', 1 do
			post existing_member_requests_path, membership_application: { name: "Brian Someone", playa_name: " ", email: "brian3@examaple.com" }
		end		

		member = assigns(:existing_member_request)

		assert_equal 0, ActionMailer::Base.deliveries.count
		# ActionMailer::Base.deliveries.clear

		assert_redirected_to root_url
		follow_redirect!
		assert_template 'static_pages/home'
		# membership_ap.reload

		# assert_match membership_app.name.to_s, response.body 
		assert_not member.approved?

		#post app with valid fields with playa name
		assert_difference 'MembershipApplication.count', 1 do
			post existing_member_requests_path, membership_application: { 	name: "Brian Someone", 
																			playa_name: "Hoochie Mamma", 
																			email: "brian2@examaple.com" }
		end		

		member = assigns(:existing_member_request)

		assert_equal 0, ActionMailer::Base.deliveries.count
		
		assert_redirected_to root_url
		follow_redirect!
		assert_template 'static_pages/home'
		# membership_app.reload
		# assert_match membership_app.playa_name.to_s, response.body 
		assert_not member.approved?

	end

end
