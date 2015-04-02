require 'test_helper'

class VerifyTicketsControllerTest < ActionController::TestCase
  
def setup
	@ticket = tickets(:one)
	@ticket.verification_token = Ticket.new_token
end

  test "should get edit" do
    get :edit, id: @ticket.verification_token, email: @ticket.email, ticket_id: @ticket.id
    assert_redirected_to root_url
  end

end
