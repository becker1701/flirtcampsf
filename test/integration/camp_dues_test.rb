require 'test_helper'

class CampDuesTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:brian)
		@user = users(:archer)
		@other_user = users(:kurt)
		@event = events(:future)
	end



	test "wrong user does not see camp dues or payments" do
		log_in_as @user
		get user_path(@other_user)
		assert_select 'div[id=?]', "user-camp-dues", count: 0
		# assert_no_match "Camp Dues: $100", response.body
		# assert_no_match "Camp Meals: $50", response.body
		# assert_no_match "Annual Yurt Storage: $75", response.body
		assert_no_match "Total Camp Dues: $225", response.body
		assert_no_match "Total Payments:", response.body
		assert_no_match "Balance:", response.body
		assert_select 'a[href=?]', user_payments_path(@other_user), count: 0
	end

	test "user not going home page will not have camp dues and payment information" do
		intention = @other_user.next_event_intention
		intention.status = :not_going_no_ticket
		intention.save!

		log_in_as @other_user
		get root_path

		assert_select 'div[id=?]', "user-camp-dues", count: 0

	end

	test "opted out of food" do
		log_in_as @admin
		
		@user.next_event_intention.toggle!(:opt_in_meals)
		assert_not @user.next_event_intention.opt_in_meals?

		get user_path(@user)
		assert_match "Balance: $175", response.body

		get user_payments_path(@user)
		assert_match "Opted out", response.body
		# assert_select 'td', text: "<strong>Balance: $175</strong>"


	end

	test "user home page camp dues and payment information" do
		log_in_as @user
  		get root_path

		@user.payments.create!(event: @event, payment_date: Date.today-5.days, amount: 100)
		@user.payments.create!(event: @event, payment_date: Date.today-3.days, amount: 75)

  		Intention.statuses.each do |status, id|

  			@user.next_event_intention.status = status.to_sym
			@user.next_event_intention.save

			get root_path

			assert_select 'a[href=?]', new_user_payment_path(@user), count: 0


  			if id == 1 || id == 2
  				# puts "Status is going #{id}"
		  		assert @user.next_event_intention.going?
		  		assert_select 'div[id=?]', "user-camp-dues", count: 1
		  		assert_select 'a[href=?]', user_payments_path(@user), count: 1
				assert_no_match "Camp Dues: $100", response.body
				assert_no_match "Camp Meals: $50", response.body
				assert_no_match "Annual Yurt Storage: $75", response.body
				assert_match "Total Camp Dues: $225", response.body
				assert_match "Total Payments: $175", response.body
				assert_match "Balance: $50", response.body
				
				assert_equal 2, @user.payments.for_next_event.count

				@user.payments.where(event: @event).each do |payment|
					assert_no_match "$#{payment.amount.to_i} paid on", response.body
					assert_no_match payment.payment_date.strftime("%a, %b %-e"), response.body
				end

			elsif id ==3 || id == 4
				# puts "Status is not going #{id}"
		  		assert_not @user.next_event_intention.going?
		  		assert_select 'a[href=?]', user_payments_path(@user), count: 0
		  		assert_select 'div[id=?]', "user-camp-dues", count: 0

				assert_no_match "Camp Dues:", response.body
				assert_no_match "Camp Meals:", response.body
				assert_no_match "Annual Yurt Storage:", response.body
				assert_no_match "Total Camp Dues:", response.body
				assert_no_match "Total Payments:", response.body
				assert_no_match "Balance:", response.body
			end
		end

		#TODO: Add payments to test



	end


  test "user show page has camp dues when admin" do

=begin
	Users with intention to go:
		Show the Camp Due div component
		Camp Dues: $100
		Meals: $50
		Container Storage: $75
		Total: $225
		Payment 1: $100 on 4/14/15
		Payment 2: $75 on 4/15/15
		Paid: $175
		Balance:  $50

	Only Admin can edit :
		Storage container option and price
		payments (both payment made or discount)
		
	No one else can see any one elses dues, payments


=end
	log_in_as @admin

	assert @user.next_event_intention.going?

	@user.payments.create!(event: @event, payment_date: Date.today-5.days, amount: 50)
	@user.payments.create!(event: @event, payment_date: Date.today-3.days, amount: 75)
	
	get user_path @user

	assert_select 'div[id=?]', "user-camp-dues", count: 1
	assert_select 'a[href=?]', user_payments_path(@user), count: 1
	assert_select 'a[href=?]', new_user_payment_path(@user), count: 1
	assert_no_match "Camp Dues: $100", response.body
	assert_no_match "Camp Meals: $50", response.body
	assert_no_match "Annual Yurt Storage: $75", response.body
	assert_match "Total Camp Dues: $225", response.body
	assert_match "Total Payments: $125", response.body
	assert_match "Balance: $100", response.body

	assert_equal 2, @user.payments.for_next_event.count

	@user.payments.where(event: @event).each do |payment|
		assert_no_match "$#{payment.amount.to_i} paid on", response.body
		assert_no_match payment.payment_date.strftime("%a, %b %-e"), response.body
	end

  end

  test "user payment index show all next_event payments and dues breakdown" do
  	
  	@user.payments.create!(event: @event, payment_date: Date.today-5.days, amount: 50)
	@user.payments.create!(event: @event, payment_date: Date.today-3.days, amount: 75)
	@user.payments.create!(event: events(:past), payment_date: Date.today-1.year, amount: 75)

  	log_in_as @user
  	assert @user.next_event_intention.going?

  	get user_payments_path(@user)

  	assert_response :success
  	assert_template 'payments/index'

  	assert_select 'a[href=?]', root_path, text: "Back to profile", count: 1

  	payments = assigns(:payments)
  	
  	@user.payments.each do |payment|
  		if payment.event == @event
  			assert_includes payments, payment
  			assert_select 'tr[id=?]', "user_payment_id_#{payment.id}"
  			assert_select 'a[href=?]', edit_user_payment_path(@user, payment), count: 0
  		else
  			assert_not_includes payments, payment
  			assert_select 'tr[id=?]', "user_payment_id_#{payment.id}", count: 0
  		end
  		
  		assert_select 'a', text: "Delete", count: 0
  	end

  	assert_select 'a[href=?]', new_user_payment_path(@user), count: 0 #admin only

  end


  test "user payment index show all next_event payments and dues breakdown for admin" do
  	
  	@user.payments.create!(event: @event, payment_date: Date.today-5.days, amount: 50)
	@user.payments.create!(event: @event, payment_date: Date.today-3.days, amount: 75)
	@user.payments.create!(event: events(:past), payment_date: Date.today-1.year, amount: 75)

  	log_in_as @admin

  	assert @user.next_event_intention.going?

  	get user_payments_path(@user)

  	assert_response :success
  	assert_template 'payments/index'
	assert_select 'a[href=?]', user_path(@user), text: "Back to profile", count: 1
  	
  	assert_equal @user, assigns(:user)
  	payments = assigns(:payments)
  	
  	@user.payments.each do |payment|
  		assert_equal @user.id, payment.user_id
  		if payment.event == @event
  			assert_includes payments, payment
  			assert_select 'tr[id=?]', "user_payment_id_#{payment.id}"
  			assert_select 'a[href=?]', edit_user_payment_path(@user, payment), count: 1
  		else
  			assert_not_includes payments, payment
  			assert_select 'tr[id=?]', "user_payment_id_#{payment.id}", count: 0
  		end
  		
  		assert_select 'a', text: "Delete", count: 2
  	end

  	assert_select 'a[href=?]', new_user_payment_path(@user), count: 1 #admin only

  end



  test "edit payment" do
  	
  	payment = @user.payments.create!(event: @event, payment_date: Date.today-3.days, amount: 75)

  	log_in_as @other_user

  	get edit_user_payment_path(@user, payment)
  	assert_redirected_to root_url

  	delete logout_path

  	log_in_as @admin
  	get edit_user_payment_path(@user, payment)

  	assert_template 'payments/edit'
  	assert_equal payment, assigns(:payment)

  	# assert_select 'form[name=?]', "payment"
  	assert_match @user.name, response.body
  end


  test "camp overview for admin" do
  	log_in_as @user
  	get camp_dues_overview_event_path(@event)

  	assert_redirected_to root_url

  	delete logout_path

  	log_in_as @admin
  	get camp_dues_overview_event_path(@event)
  	assert_template 'events/camp_dues_overview'
  	
  	users = assigns(:users)

  	assert_equal @event, assigns(:event)
  	assert_equal User.joins(:intentions).where(intentions: {status: [1,2], event_id: @event.id}).references(:intentions), assigns(:users)

  	users.each do |user|
  		user.payments.create(event: @event, payment_date: Date.today - 5.days, amount: 75)
  	end

  	get camp_dues_overview_event_path(@event)

  	users.each do |user|
  		assert_equal 1, user.payments.count
  		assert_select 'tr[id=?]', "user_id_#{user.id}" do 
			assert_match "$#{user.sum_camp_dues.to_i}", response.body
			assert_match "$#{user.sum_next_event_payments.to_i}", response.body
			assert_match "$#{user.next_event_camp_dues_balance.to_i}", response.body
			assert_select 'a[href=?]', new_user_payment_path(user), count: 1
			assert_select 'a[href=?]', user_payments_path(user), count: 1
  		end
  	end

  end

end
