require 'test_helper'

class ExistingMemberRequestsControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
    assert_template 'existing_member_requests/new'
  end

end
