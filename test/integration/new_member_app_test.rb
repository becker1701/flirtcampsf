require 'test_helper'

class NewMemberAppTest < ActionDispatch::IntegrationTest

	def setup
		ActionMailer::Base.deliveries.clear
	end

	# new members will visit flirt camp website and click on 'New Member App' button
	# They will be redirected to page 1 of the 'New Member App' with all of the logistics and agreements.
	# they will then fill in their contact info
	# then they will answer questions about why they want to be in Flirt Camp
	# Question regarding how many years they have been going to BM, yada, yada
	test "guests new member app funtionality" do
		get '/new_member_app'
		assert_template 'static_pages/new_member_app'
		assert_not is_logged_in?
		assert_select 'h1', text: "New Member App"
		assert_select 'a[href=?]', new_membership_application_path

		get new_membership_application_path
		assert_template 'membership_applications/new'
		assert_select 'h1', text: "Flirt Camp New Member Application"

		assert_not is_logged_in?

		#post app with invalid fields
		assert_no_difference 'MembershipApplication.count' do
			post membership_applications_path, membership_application: { birth_name: " ", playa_name: "test", email: " ", 
																			phone: " ", home_town: " ", possibility: " ", 
																			contribution: " ", passions: " ", years_at_bm: " ", 
																			approved: false }
		end

		assert_template 'membership_applications/new'
		assert_select 'div#error_explanation'	
		assert flash.empty?
		assert_select 'input[value=?]', "test"
		assert_equal 0, ActionMailer::Base.deliveries.count

		#post app with valid fields without playa name
		assert_difference 'MembershipApplication.count', 1 do
			post membership_applications_path, membership_application: { birth_name: "Brian Someone", playa_name: " ", email: "brian3@examaple.com", 
																			phone: "(123) 456-7890", home_town: "Some Town, CA", 
																			possibility: "Some amoutn of text that says this", 
																			contribution: "Some amoutn of text that says this", 
																			passions: "Some amoutn of text that says this", 
																			years_at_bm: "1", approved: false }
		end		

		membership_app = assigns(:membership_app)

		assert_equal 1, ActionMailer::Base.deliveries.count
		mail = ActionMailer::Base.deliveries.last
		assert_equal mail.to, membership_app.email

		

		assert_redirected_to thank_you_membership_application_path(membership_app)
		follow_redirect!
		assert_template 'membership_applications/thank_you'
		membership_app.reload
		# debugger
		assert_match membership_app.birth_name.to_s, response.body 
		assert_not membership_app.approved?


		ActionMailer::Base.deliveries.clear

		#post app with valid fields with playa name
		assert_difference 'MembershipApplication.count', 1 do
			# debugger
			post membership_applications_path, membership_application: { 	birth_name: "Brian Someone", 
																			playa_name: "Hoochie Mamma", 
																			email: "brian2@examaple.com", 
																			phone: "(123) 456-7890", 
																			home_town: "Some Town, CA", 
																			possibility: "Some amoutn of text that says this", 
																			contribution: "Some amoutn of text that says this", 
																			passions: "Some amoutn of text that says this", 
																			years_at_bm: "1", 
																			approved: false }
		end		

		membership_app = assigns(:membership_app)

		assert_equal 1, ActionMailer::Base.deliveries.count
		mail = ActionMailer::Base.deliveries.last
		assert_equal mail.to, membership_app.email
		
		assert_redirected_to thank_you_membership_application_path(membership_app)
		follow_redirect!
		assert_template 'membership_applications/thank_you'
		membership_app.reload
		assert_match membership_app.playa_name.to_s, response.body 
		assert_not membership_app.approved?


	end



end
