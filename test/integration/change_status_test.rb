require 'test_helper'

class ChangeStatusTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
  	@user = users(:archer)
  	@event = events(:future)
  	# @intention = @user.intentions.find_by(event: @event)
  	# assert_not @intention.nil?

  end

  test "sucessfully changes intention status" do

  	log_in_as @user
  	get root_url

  	intention = assigns(:intention)
  	assert_not intention.new_record?

  	assert_select "a[href=?]", edit_event_intention_path(@event, intention)

  	get edit_event_intention_path(@event, intention)

  	assert_select 'form select[name=?]', 'intention[status]'

  	#test for invalid intention (no status)
  	patch event_intention_path(@event, intention), intention: { status: nil }

  	# follow_redirect!
  	assert_template 'intentions/edit'
  	assert_not flash.empty?
    assert_select 'div.alert-danger'

  	patch event_intention_path(@event, intention), intention: { status: :not_going_no_ticket, yurt_user: "Some bitch"}
  	assert_equal "Some bitch", intention.reload.yurt_user
  	assert_redirected_to root_url

  	get edit_event_intention_path(@event, intention)
   	patch event_intention_path(@event, intention), intention: { status: :going_has_ticket, yurt_user: "Some Otherbitch"}
  	assert_equal "Some Otherbitch", intention.reload.yurt_user
  	follow_redirect! 
  	assert_template 'static_pages/home'
  	

  end


end
