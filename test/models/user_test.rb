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

  test "valid if phone = 20 char." do
    @user.phone = "1" * 20
    assert @user.valid?
  end

  test "invlalid if phone number > 20 char." do
    @user.phone = "1" * 21
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

end
