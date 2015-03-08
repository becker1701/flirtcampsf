require 'test_helper'

class MembershipApplicationsControllerTest < ActionController::TestCase
  
	def setup
	end

	test "get new" do
		get :new
		assert_response :success
		assert_select "title", full_title("Membership Application")
	end

	test "POST invalid info" do
		assert_no_difference 'MembershipApplication.count' do 
			post :create, membership_application: { birth_name: " "}
		end
		assert_template 'membership_applications/new'
	end

	test "POST valid info" do
		assert_difference 'MembershipApplication.count', 1 do
			post :create, membership_application: { birth_name: "Brian Someone", playa_name: "Hoochie Mamma", email: "brian1@examaple.com", 
																			phone: "(123) 456-7890", home_town: "Some Town, CA", 
																			possibility: "Some amoutn of text that says this", 
																			contribution: "Some amoutn of text that says this", 
																			passions: "Some amoutn of text that says this", 
																			years_at_bm: "1", approved: false }
		end

		member_app = assigns(:membership_app)
		assert_equal "Brian Someone", member_app.birth_name
		assert_response :redirect
		assert_redirected_to thank_you_membership_application_path(member_app)

		

	end



end