require 'test_helper'

class EarlyArrivalTest < ActiveSupport::TestCase
  def setup
  	@event = events(:future)
  	@user_1 = users(:archer)
  	# @user_2 = users(:kurt)
  	@ea = @event.early_arrivals.build(user: @user_1)
  end

  test "valid" do
  	assert @ea.valid?
  end

  test "invalid without event" do
  	@ea.event = nil
  	assert_not @ea.valid?
  end 

  test "invalid without user" do
  	@ea.user = nil
  	assert_not @ea.valid?
  end

end
