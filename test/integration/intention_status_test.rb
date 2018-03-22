require 'test_helper'

class IntentionStatusTest < ActionDispatch::IntegrationTest

  def setup
  	@user = users(:brian)
    @admin = users(:brian)
  	@intention = intentions(:for_brian)
  	@event = events(:future)
  end

  test "intentions/status partial" do
  	log_in_as @user
  	@intention.save!

  	@intention.update_attribute(:status, :going_has_ticket)

  	get root_path
  	assert_match "I will be attending #{@event.year} with Flirt Camp.", response.body
  	assert_match "I have secured tickets.", response.body


	@intention.update_attribute(:status, :going_needs_ticket)

  	get root_path
  	assert_match "I will be attending #{@event.year} with Flirt Camp.", response.body
  	assert_match "I have NOT secured tickets.", response.body


	@intention.update_attribute(:status, :not_going_has_ticket)

  	get root_path
  	assert_match "I will NOT be attending #{@event.year} with Flirt Camp.", response.body


	@intention.update_attribute(:status, :not_going_no_ticket)

  	get root_path
  	assert_match "I will NOT be attending #{@event.year} with Flirt Camp.", response.body

  end


  test "admin can access user intention edit" do
    log_in_as @admin

    intention = intentions(:for_archer)
    intention_user = intention.user

    get edit_event_intention_path(@event, intention)

    #

    assert_response :success
    assert_template 'intentions/edit'

    assigned_intention = assigns(:intention)

    assert_match @event.year, response.body
    assert_match intention_user.name, response.body

    assert_equal intention, assigned_intention
    assert_equal intention_user, assigned_intention.user

  end


  test "wrong user can not access another user intention edit" do
    log_in_as users(:kurt)

    intention = intentions(:for_archer)

    get edit_event_intention_path(@event, intention)

    assert_redirected_to root_path

  end


end
