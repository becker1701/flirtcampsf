require 'test_helper'

class MembershipApplicationDeleteTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:brian)

		@member_app = membership_applications(:member_app_1)
	end

	test "non admin can not delete membership application" do

		#only admin can see membership app delete
		get membership_applications_path
		assert_redirected_to login_path

		log_in_as users(:archer)
		get membership_applications_path
		assert_redirected_to root_path

	end

	test "admin can delete membership app" do

		log_in_as @admin
		get membership_applications_path

		member_apps = assigns(:membership_applications)
		assert_not member_apps.empty?

		# debugger
		member_apps.each do |app|
			assert_select 'tr[id=?]', "member_app_#{app.id}" do
				assert_select 'a', text: "X"
			end
		end

		assert_difference 'MembershipApplication.count', -1 do
			delete membership_application_path(@member_app)
		end

		assert_redirected_to membership_applications_path
		follow_redirect!

		#check to see if the membership app is still on the page
		assert_select 'tr[id=?]', "member_app_#{@member_app.id}", count: 0

	end

end
