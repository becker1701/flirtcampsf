require 'test_helper'

class TicketTest < ActiveSupport::TestCase
  def setup
  	@event = events(:future)
  	@ticket = @event.tickets.build(name: "Brad Pitt", email: "brad@example.com", admission_qty: 1, parking_qty: 1, confirmation_number: "123456ABC" )
  end

  test "is valid" do
  	assert tickets(:one).valid?
  	assert tickets(:two).valid?
  	assert @ticket.valid?
  end

  test "invalid without email" do
  	@ticket.email = " "
  	assert_not @ticket.valid?
  end

  test "invalid without both admission and parking qty" do
  	@ticket.admission_qty = 0
  	@ticket.parking_qty = 0

  	assert_not @ticket.valid?
  end

   test "is invalid with name > 50 characters" do
  	@ticket.name = "a" * 51
  	assert_not @ticket.valid?
  end

   test "is invalid with confirmation_number  > 30 characters" do
  	@ticket.confirmation_number = "a" * 31
  	assert_not @ticket.valid?
  end

  test "is invalid with email > 255 characters" do
  	@ticket.email = "a" * 256
  	assert_not @ticket.valid?
  end

  test "email validation passes with valid email addresses" do
  	valid_addresses = %w[user@example.com USER@foo.COM  A_US-ER@foo.bar.org first.last@foo.jp  alice+bob@baz.cn user.54@example.com first.la_st@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_email|
    	@ticket.email = valid_email
    	assert @ticket.valid?, "#{valid_email.inspect} should be a valid email address."
    end
  end

  test "email validation does not pass with invalid email addresses" do
  	invalid_addresses = %w[user@example..com user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com user@ example.com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_email|
    	@ticket.email = invalid_email
    	assert_not @ticket.valid?, "#{invalid_email.inspect} should not be a valid email address."
    end
  end  

  test "message for invalid email format" do
  	@ticket.email = "user@example,com"
  	@ticket.valid?
  	assert_includes @ticket.errors.full_messages, "Email is not a recognized format."
  end

  test "duplicate email not valid" do
  	duplicate_user = @ticket.dup
  	@ticket.save
  	assert_not duplicate_user.valid?
  end

  test "duplicate email invalid with different case" do
  	duplicate_user = @ticket.dup
  	duplicate_user.email.upcase!
  	@ticket.save
  	# puts "dup_user: #{duplicate_user.email}  @ticket: #{@ticket.email}"
  	assert_not duplicate_user.valid?
  end

  test "email saves downcased" do
  	mixed_case_email = "dAvE@eXampLe.Com"
  	@ticket.email = mixed_case_email
  	@ticket.save
  	@ticket.reload
  	assert_equal @ticket.email, mixed_case_email.downcase
  end

  test "ticket status" do
  	@ticket.status = 1
  	assert @ticket.for_sale?

  	@ticket.status = 2
  	assert @ticket.sold?
  end

  test "verified tickets" do
    verified_tickets = @event.tickets.verified
    assert_equal 2, verified_tickets.count
    verified_tickets.each do |ticket|
      assert ticket.verified?
    end


  end

  # test "responds to verification_token" do
  #   assert @ticket.verification_token
  # end

end
