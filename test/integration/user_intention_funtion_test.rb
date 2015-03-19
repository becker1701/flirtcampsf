require 'test_helper'

class UserIntentionFunctionTest < ActionDispatch::IntegrationTest
  
	def setup
		@user = users(:archer)
		@event = events(:future)

	end

	test "user_intentions" do
		
	end

end
