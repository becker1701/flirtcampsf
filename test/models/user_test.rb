require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
  	@user = User.new(name: "Ray Ban", email: "ray@example.com", password: "foobar", password_confirmation: "foobar", phone: "123-456-7890", playa_name: "Camp Master")
  end

  test "is valid" do
  	assert @user.valid?
  end

  test "is invalid without name" do
  	@user.name = "  "
  	assert_not @user.valid?
  end

  test "is invalid without email" do
  	@user.email = "  "
  	assert_not @user.valid?
  end

  test "is invalid with name > 50 characters" do
  	@user.name = "a" * 51
  	assert_not @user.valid?
  end

  test "is invalid with email > 255 characters" do
  	@user.email = "a" * 256
  	assert_not @user.valid?
  end

  test "is valid without playa name" do
    @user.playa_name = nil
    assert @user.valid?
  end

  test "is invalid with playa_name > 50 characters" do
    @user.playa_name = "a" * 51
    assert_not @user.valid?
  end

  test "valid if phone = 30 char." do
    @user.phone = "1" * 30
    assert @user.valid?
  end

  test "invlalid if phone number > 30 char." do
    @user.phone = "1" * 31
    assert_not @user.valid?
  end

  test "email validation passes with valid email addresses" do
  	valid_addresses = %w[user@example.com USER@foo.COM  A_US-ER@foo.bar.org first.last@foo.jp  alice+bob@baz.cn user.54@example.com first.la_st@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_email|
    	@user.email = valid_email
    	assert @user.valid?, "#{valid_email.inspect} should be a valid email address."
    end
  end

  test "email validation does not pass with invalid email addresses" do
  	invalid_addresses = %w[user@example..com user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com user@ example.com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_email|
    	@user.email = invalid_email
    	assert_not @user.valid?, "#{invalid_email.inspect} should not be a valid email address."
    end
  end

  test "message for invalid email format" do
  	@user.email = "user@example,com"
  	@user.valid?
  	assert_includes @user.errors.full_messages, "Email is not a recognized format."
  end

  test "duplicate email not valid" do
  	duplicate_user = @user.dup
  	@user.save
  	assert_not duplicate_user.valid?
  end

  test "duplicate email invalid with different case" do
  	duplicate_user = @user.dup
  	duplicate_user.email.upcase!
  	@user.save
  	# puts "dup_user: #{duplicate_user.email}  @user: #{@user.email}"
  	assert_not duplicate_user.valid?
  end

  test "email saves downcased" do
  	mixed_case_email = "dAvE@eXampLe.Com"
  	@user.email = mixed_case_email
  	@user.save
  	@user.reload
  	assert_equal @user.email, mixed_case_email.downcase
  end

  test "is invalid when password is < 6 characters" do
  	@user.password = @user.password_confirmation = "a" * 5
  	assert_not @user.valid?
  end

  test "authenticate? returns false if remember_digest is nil" do
    assert_not @user.authenticated?(:remember, '')
  end


  test "sets #next_event_intention equal to next event" do
    event = events(:future)
    assert @user.next_event_intention.nil?
    @user.email = "someemail@otheremail.com"
    @user.save!
    #
    @user.intentions.create!(event: event, status: :going_has_ticket)
    assert_equal event, @user.reload.next_event_intention.event
  end

  test "#next_event_intention return nil if next event is nil" do
    Event.destroy_all
    assert_nil Event.next_event
    assert_nil @user.next_event_intention

  end

  test "attending_next_event" do
    #return all users whose intention status are attenting the next_event
    event = events(:future)
    intentions_user_id = event.intentions.where(status: [1,2]).pluck(:user_id).to_a
    users = User.where(id: intentions_user_id).order(:id)
    assert_equal users.to_a, User.attending_next_event.order(:id).to_a

  end

  test "not_attending_next_event" do
    #return all users whose intention status are attenting the next_event
    event = events(:future)
    intentions_user_id = event.intentions.where(status: [3,4]).pluck(:user_id).to_a
    users = User.where(id: intentions_user_id).order(:id)
    assert_equal users.to_a, User.not_attending_next_event.order(:id).to_a

  end


  test "not_responded_to_next_event" do
    event = events(:future)
    User.activated.each do |user|
      if user.next_event_intention.nil?
        assert_includes User.activated.not_responded_to_next_event, user
      else
        assert_not_includes User.activated.not_responded_to_next_event, user
      end
    end

  end

  test "has_ticket_to_next_event" do
    event = events(:future)

    User.activated.each do |user|
      if user.next_event_intention.nil?
        assert_not_includes User.activated.has_ticket_to_next_event, user
      else
        #
        if user.next_event_intention.status == "going_has_ticket" || user.next_event_intention.status == "not_going_has_ticket"
          assert_includes User.activated.has_ticket_to_next_event, user
        else
          # puts "intention status: #{user.next_event_intention.status}"
          assert_not_includes User.activated.has_ticket_to_next_event, user
        end
      end
    end

  end


  test "heeds_ticket_to_next_event" do
    event = events(:future)

    User.activated.each do |user|
      if user.next_event_intention.nil?
        assert_not_includes User.activated.needs_ticket_to_next_event, user
      else
        #
        if user.next_event_intention.status == "going_needs_ticket"

          assert_includes User.activated.needs_ticket_to_next_event, user
        else
          # puts "intention status: #{user.next_event_intention.status}"
          assert_not_includes User.activated.needs_ticket_to_next_event, user
        end
      end
    end

  end


  test "driving_to_next_event" do
    event = events(:future)

    User.activated.each do |user|
      if user.next_event_intention.nil?
        assert_not_includes User.activated.driving_to_next_event, user
      else
        #
        if user.next_event_intention.transportation == "driving"

          assert_includes User.activated.driving_to_next_event, user
        else
          # puts "intention status: #{user.next_event_intention.status}"
          assert_not_includes User.activated.driving_to_next_event, user
        end
      end
    end

  end

  test "early_arrival_to_next_event" do
    event = events(:future)

    assert_equal 3, User.activated.early_arrivals_next_event.count

    User.activated.each do |user|
      if user.ea_exists?(event)
        assert_includes User.activated.early_arrivals_next_event, user
      else
        assert_not_includes User.activated.early_arrivals_next_event, user
      end
    end

  end




  test "early arrival association exists" do
    assert_empty @user.early_arrivals
  end

  test "assign_ea adds and unassign_ea deletes and ea_exists? return TF for early_arrival record for user" do

    assert @user.valid?
    @user.save!
    event = events(:future)

    assert_empty @user.early_arrivals

    assert_not @user.ea_exists?(event)

    assert_difference 'EarlyArrival.count', 1 do
      @user.assign_ea(event)
    end

    ea = EarlyArrival.last

    assert @user.ea_exists?(event)

    assert_not_empty @user.early_arrivals
    assert_equal ea, @user.early_arrivals.find_by(event: event)
    assert_equal 1, @user.early_arrivals.count

    assert_difference 'EarlyArrival.count', -1 do
      @user.unassign_ea(event)
      # debugger
    end

    assert_not @user.ea_exists?(event)
    assert_empty @user.reload.early_arrivals

  end


  test "user notes are deleted when user is deleted" do
    user = users(:archer)
    assert_not user.user_notes.empty?
    assert_equal 5, user.user_notes.count

    assert_difference 'UserNote.count', -5 do
      user.destroy
    end
  end

  test "sum of user camp dues" do

    user = users(:archer)
    #with fod_option
    assert_equal 225, user.sum_camp_dues

    #without food option
    user.next_event_intention.toggle!(:opt_in_meals)
    assert_equal 175, user.sum_camp_dues.to_i
  end

  test "#first_name returns first name" do

    user = users(:archer)
    assert_equal "Archer Baker", user.name
    assert_equal "Archer", user.first_name

    user.name = "Archer Baker Something"

    assert_equal "Archer", user.first_name

    user.name = "Archer"
    assert_equal "Archer", user.first_name

    user.name = " "
    assert_nil user.first_name

  end

  test "next_event_total_camp_dues" do
    assert_equal 450, User.next_event_camp_dues
  end

  test "next_event_payments" do
    @user.save
    @user.payments.create(event: events(:future), payment_date: Date.today, amount: 100)
    @user.payments.create(event: events(:past), payment_date: Date.today, amount: 100)
    assert_equal 100, User.next_event_payments
  end

  test "next_event_camp_due_balance" do

    @user.save
    @user.payments.create(event: events(:future), payment_date: Date.today, amount: 100)
    @user.payments.create(event: events(:past), payment_date: Date.today, amount: 100)
    assert_equal 350, User.next_event_balance
  end

end
