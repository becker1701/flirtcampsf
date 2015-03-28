require 'test_helper'

class IntentionStatusTest < ActionDispatch::IntegrationTest
  
  def setup
  	@user = users(:brian)
  	@intention = intentions(:one)
  	@event = events(:future)
  end

  test "intentions/status partial" do
  	log_in_as @user
  	@intention.save!

  	@intention.update_attribute(:status, :going_has_ticket)

  	get root_path
  	assert_match "I will be attending #{@event.year}.", response.body
  	assert_match "I have secured tickets.", response.body


	@intention.update_attribute(:status, :going_needs_ticket)

  	get root_path
  	assert_match "I will be attending #{@event.year}.", response.body
  	assert_match "I have NOT secured tickets.", response.body


	@intention.update_attribute(:status, :not_going_has_ticket)

  	get root_path
  	assert_match "I will NOT be attending #{@event.year}.", response.body
  	assert_match "I will be selling my secured tickets.", response.body


	@intention.update_attribute(:status, :not_going_no_ticket)

  	get root_path
  	assert_match "I will NOT be attending #{@event.year}.", response.body
  	assert_match "I have NO secured tickets.", response.body

  end
end
