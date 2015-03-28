require 'test_helper'

class UserIndexOptimizeTest < ActionDispatch::IntegrationTest
  
	def setup
		@event = events(:future)
		@user = users(:archer)
	end

	test "index returning all users" do
		log_in_as @user
		get users_path
		assert_not_nil assigns(:users)
		# debugger
		# puts User.where(activated: true).count
		# puts assigns(:users).count
		assert_equal User.activated.count, assigns(:users).count

	end

end
