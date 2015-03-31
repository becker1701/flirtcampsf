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
			post membership_applications_path, membership_application: { name: " ", playa_name: "test", email: " ", 
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
			post membership_applications_path, membership_application: { name: "Brian Someone", playa_name: " ", email: "brian3@examaple.com", 
																			phone: "(123) 456-7890", home_town: "Some Town, CA", 
																			possibility: "Some amoutn of text that says this", 
																			contribution: "Some amoutn of text that says this", 
																			passions: "Some amoutn of text that says this", 
																			years_at_bm: "1", approved: false }
		end		

		membership_app = assigns(:membership_app)

		assert_equal 2, ActionMailer::Base.deliveries.count
		ActionMailer::Base.deliveries.clear

		assert_redirected_to thank_you_membership_application_path(membership_app)
		follow_redirect!
		assert_template 'membership_applications/thank_you'
		membership_app.reload

		assert_match membership_app.name.to_s, response.body 
		assert_not membership_app.approved?

		#post app with valid fields with playa name
		assert_difference 'MembershipApplication.count', 1 do
			post membership_applications_path, membership_application: { 	name: "Brian Someone", 
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

		assert_equal 2, ActionMailer::Base.deliveries.count
		
		assert_redirected_to thank_you_membership_application_path(membership_app)
		follow_redirect!
		assert_template 'membership_applications/thank_you'
		membership_app.reload
		assert_match membership_app.playa_name.to_s, response.body 
		assert_not membership_app.approved?

	end


	test "mail delivered after valid submission" do
		assert_difference 'MembershipApplication.count', 1 do
			# debugger
			post membership_applications_path, membership_application: { 	name: "Brian Someone", 
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

		assert_equal 2, ActionMailer::Base.deliveries.count

		thank_you_mail = ActionMailer::Base.deliveries.first
		org_notify_mail = ActionMailer::Base.deliveries.last

		assert_equal thank_you_mail.to.pop, membership_app.email
		assert_equal org_notify_mail.to.pop, "campmaster@flirtcampsf.com"
	end


	test "membership application index" do
		admin = users(:brian)
		log_in_as admin
		get membership_applications_path
		# follow_redirect!
		assert_template 'membership_applications/index'
		assert is_logged_in?

		member_apps = assigns(:membership_applications)
		assert_equal 21, member_apps.count

		member_apps.first.update_attribute(:approved, nil)
		member_apps.reload
		get membership_applications_path

		member_apps.each do |app|
			assert_select 'a[href=?]', edit_membership_application_path(app)

			if app.approved.nil?
				# debugger
				assert_select 'a[href=?]', approve_membership_application_path(app)
				assert_select 'a[href=?]', decline_membership_application_path(app)	
			else
				# debugger
				assert_select 'a[href=?]', approve_membership_application_path(app), count: 0
				assert_select 'a[href=?]', decline_membership_application_path(app), count: 0
			end
		end
	end

end
