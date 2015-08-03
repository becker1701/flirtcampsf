require 'test_helper'

class EarlyArrivalIntegrationTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
  	@event = events(:future)
  	@user = users(:archer)
  	@admin = users(:brian)
    @ea = early_arrivals(:ea_archer)
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
  		assert_select 'tr[id=?]', "ea_id_#{ea.id}" do
  			assert_select 'a[href=?]', user_path(ea.user)
  			assert_select 'a[href=?]', event_early_arrival_path(@event, ea), text: "Remove"
  		end
  	end

  end

  test "assign early arrival member" do
  		
  	@user.early_arrivals.destroy_all
  	@user.reload

  	log_in_as @admin
  	get user_path(@user)


  	assert_select 'form[action=?]', event_early_arrivals_path(@event)
  	assert_select 'input[type=?]', 'submit', value: "Assign to Early Arrival"

  	assert_difference 'EarlyArrival.count', 1 do
  		# @user.assign_ea(@event)
  		post event_early_arrivals_path(@event), early_arrival: { user_id: @user.id }
  	end

  	ea = assigns(:ea)

  	assert_redirected_to user_path(@user)
  	follow_redirect!

  	
  	assert_select 'form[action=?]', event_early_arrival_path(@event, ea)
  	assert_select 'input[type=?]', 'submit', value: "Unassign from Early Arrival"
  	
# debugger
  	assert_difference 'EarlyArrival.count', -1 do
  		delete event_early_arrival_path(@event, ea)
  		
  	end
  	assert_redirected_to user_path(@user)

  	#get list of users NOT already in the EA list

  end


  test "early arrival auth date shows on user profile" do

    log_in_as @admin

    patch event_early_arrival_path(@event, @ea), early_arrival: { ea_date: @event.extended_date_range.third }
    
    assert_equal @event.extended_date_range.third, @ea.reload.ea_date

    log_out

    log_in_as @user

    get root_path
    assert_select 'h3', text: "Early Arrival Info"
    assert_select 'span[id=?]', "ea_date", { text: strf_day(@ea.ea_date) }

  end


  test "early arrival auth date shows TBD on user profile when nil" do

    log_in_as @admin

    # patch event_early_arrival_path(@event, @ea), early_arrival: { ea_date: @event.extended_date_range.third }
    
    assert_nil @ea.reload.ea_date

    log_out

    log_in_as @user

    get root_path
    assert_select 'h3', text: "Early Arrival Info"
    assert_select 'span[id=?]', "ea_date", { text: "TBD" }

  end

  test "early arrival does not show for user that is not early arrival" do

    

    log_in_as users(:elisabeth)

    get root_path
    assert_select 'h3', text: "Early Arrival Info", count: 0
    assert_select 'span[id=?]', "ea_date", { text: strf_day(@ea.ea_date), count: 0 } 

  end


end
