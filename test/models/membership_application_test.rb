require 'test_helper'

class MembershipApplicationTest < ActiveSupport::TestCase

	def setup
		@membership_app = MembershipApplication.new(birth_name: "MyString", 
													playa_name: "MyString", 
													email: "email@example.com", 
													phone: "(123) 456-7890", 
													home_town: "Some Town, CA", 
													possibility: "Some possibility of camping", 
													contribution: "Some Contribution", 
													passions: "Some passion", 
													years_at_bm: 1, 
													approved: nil)
	end

	test "is valid" do
		assert @membership_app.valid?
	end

	test "invlid without birth_name" do
		@membership_app.birth_name = " "
		assert_not @membership_app.valid?
	end

	test "is invalid without email" do
		@membership_app.email = "  "
		assert_not @membership_app.valid?
	end

	test "is invalid with name > 50 characters" do
		@membership_app.birth_name = "a" * 51
		assert_not @membership_app.valid?
	end

	test "is invalid with email > 255 characters" do
		@membership_app.email = "a" * 256
		assert_not @membership_app.valid?
	end

	test "is valid without playa name" do
	@membership_app.playa_name = nil
	assert @membership_app.valid?
	end

	test "is invalid with playa_name > 50 characters" do
	@membership_app.playa_name = "a" * 51
	assert_not @membership_app.valid?
	end

	test "valid if phone = 30 char." do
	@membership_app.phone = "1" * 30
	assert @membership_app.valid?
	end

	test "invlalid if phone number > 30 char." do
	@membership_app.phone = "1" * 31
	assert_not @membership_app.valid?
	end

	test "email validation passes with valid email addresses" do
		valid_addresses = %w[user@example.com USER@foo.COM  A_US-ER@foo.bar.org first.last@foo.jp  alice+bob@baz.cn user.54@example.com first.la_st@foo.jp alice+bob@baz.cn]
	valid_addresses.each do |valid_email|
		@membership_app.email = valid_email
		assert @membership_app.valid?, "#{valid_email.inspect} should be a valid email address."
	end
	end

	test "email validation does not pass with invalid email addresses" do
		invalid_addresses = %w[user@example..com user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com user@ example.com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
	invalid_addresses.each do |invalid_email|
		@membership_app.email = invalid_email
		assert_not @membership_app.valid?, "#{invalid_email.inspect} should not be a valid email address."
	end
	end  

	test "message for invalid email format" do
		@membership_app.email = "user@example,com"
		@membership_app.valid?
		assert_includes @membership_app.errors.full_messages, "Email is not a recognized format."
	end

	test "duplicate email not valid" do
		duplicate_user = @membership_app.dup
		@membership_app.save
		assert_not duplicate_user.valid?
	end

	test "duplicate email invalid with different case" do
		duplicate_user = @membership_app.dup
		duplicate_user.email.upcase!
		@membership_app.save
		# puts "dup_user: #{duplicate_user.email}  @user: #{@membership_app.email}"
		assert_not duplicate_user.valid?
	end

	test "email saves downcased" do
		mixed_case_email = "dAvE@eXampLe.Com"
		@membership_app.email = mixed_case_email
		@membership_app.save
		@membership_app.reload
		assert_equal @membership_app.email, mixed_case_email.downcase
	end

	test "scope: not_approved" do

		#starting with 21 fixtures
		#subtract 3 fixtures
		MembershipApplication.first(3).each do |app|
			app.toggle!(:approved)
		end
		assert_equal 18, MembershipApplication.not_approved.count

	end

	test "#approve sets approved attribute = true" do
		assert_nil @membership_app.approved
		assert_difference 'Invitation.count', 1 do
			@membership_app.approve
		end
		assert @membership_app.reload.approved?

	end

	test "#decline sets approved attribute = false" do
		assert_nil @membership_app.approved
		assert_no_difference 'Invitation.count' do
			@membership_app.decline
		end
		assert_not @membership_app.reload.approved?
	end
end
