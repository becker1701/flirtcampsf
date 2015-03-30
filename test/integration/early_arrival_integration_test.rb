require 'test_helper'

class EarlyArrivalIntegrationTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
  	@event = events(:future)
  	@user = users(:archer)
  	@admin = users(:brian)
  end

  test "only admin user access" do
  	#only admin can access the early arrival create page
  	get event_early_arrivals_path(@event)
  	assert_redirected_to login_path

  	log_in_as @user
  	get event_early_arrivals_path(@event)
  	assert_redirected_to root_path

  	log_in_as @admin
  	get event_early_arrivals_path(@event)
  	assert_template 'early_arrivals/index'
  	assert_select 'title', full_title("Early Arrivals")
  	assert_equal @event, assigns(:event)
  	assert_not assigns(:early_arrivals).nil?

  end

  test "early arrival index page" do
  	log_in_as @admin
  	get event_early_arrivals_path(@event)

  	assert_select 'h1', text: "Early Arrivals"
  	assert_select 'small', text: @event.year

  	eas = assigns(:early_arrivals)
  	assert_not_nil eas

  	eas.each do |ea|
  		assert_select 'div[id=?]', "ea_id_#{ea.id}" do
  			assert_select 'a[href=?]', user_path(ea.user)
  			assert_select 'a[href=?]', event_early_arrival_path(@event, ea), text: "Remove from EA List"
  		end
  	end

  	assert_select 'a[href=?]', new_event_early_arrival_path
  end

  test "assign early arrival member" do
  	log_in_as @admin
  	


  	#get list of users NOT already in the EA list

  end

end
