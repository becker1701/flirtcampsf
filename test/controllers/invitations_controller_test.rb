require 'test_helper'

class InvitationsControllerTest < ActionController::TestCase
  
  def setup
	@user = users(:brian)
	@other_user = users(:archer)
    @admin = users(:admin)
  end


  test "GET new if ADMIN" do
  	log_in_as @admin
  	assert is_logged_in?

  	get :new
  	assert_response :success
  	assert_template 'invitations/new'
  end

  test "GET new if not admin" do
  	assert_not is_logged_in?
  	get :new
  	assert_redirected_to login_url
  end

  test "POST create with valid info as admin" do
  	log_in_as @admin
  	assert is_logged_in?
  	assert_difference 'Invitation.count', 1 do
  		post :create, invitation: {name: "Brian Becker", email: "campmaster@example.com"}
  	end

  	assert_redirected_to new_invitation_url
  	assert_response :redirect
  end

  test "POST create with invalid info as admin" do
  	log_in_as @admin
  	assert is_logged_in?
  	assert_no_difference 'Invitation.count' do
  		post :create, invitation: {name: " ", email: " "}
  	end
  	assert_template 'invitations/new'
  end

  test "redirect to root_url when POST and not logged in" do
   	assert_no_difference 'Invitation.count' do
  		post :create, invitation: {name: "Brian Becker", email: "campmaster@example.com"}
  	end
  	assert_redirected_to login_url
  end




end
