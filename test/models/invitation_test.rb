require 'test_helper'

class InvitationTest < ActiveSupport::TestCase
  def setup 
  	@invitation = Invitation.new(name: "Test Person", email: "test@example.com")
    ActionMailer::Base.deliveries.clear
  end

  test "is valid" do
  	assert @invitation.valid?
  end

  test "is invalid without name" do
  	@invitation.name = " "
  	assert_not @invitation.valid?
  end

  test "is invalid without email" do
  	@invitation.email = " "
  	assert_not @invitation.valid?
  end

  test "email validation passes with valid email addresses" do
  	valid_addresses = %w[user@example.com USER@foo.COM  A_US-ER@foo.bar.org first.last@foo.jp  alice+bob@baz.cn user.54@example.com first.la_st@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_email|
    	@invitation.email = valid_email
    	assert @invitation.valid?, "#{valid_email.inspect} should be a valid email address."
    end
  end

  test "email validation does not pass with invalid email addresses" do
  	invalid_addresses = %w[user@example..com user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com user@ example.com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_email|
    	@invitation.email = invalid_email
    	assert_not @invitation.valid?, "#{invalid_email.inspect} should not be a valid email address."
    end
  end  

  test "message for invalid email format" do
  	@invitation.email = "user@example,com"
  	@invitation.valid?
  	assert_includes @invitation.errors.full_messages, "Email is not a recognized format."
  end

  test "duplicate email not valid" do
  	duplicate_invitation = @invitation.dup
  	@invitation.save
  	assert_not duplicate_invitation.valid?
  end

  test "duplicate email invalid with different case" do
  	duplicate_invitation = @invitation.dup
  	duplicate_invitation.email.upcase!
  	@invitation.save
  	# puts "dup_invitation: #{duplicate_invitation.email}  @invitation: #{@invitation.email}"
  	assert_not duplicate_invitation.valid?
  end

  test "email saves downcased" do
  	mixed_case_email = "dAvE@eXampLe.Com"
  	@invitation.email = mixed_case_email
  	@invitation.save
  	@invitation.reload
  	assert_equal @invitation.email, mixed_case_email.downcase
  end

  test "returns false when #replied? with no email match in User table" do
    assert_not @invitation.replied?
  end

  test "returns User when #replied? with email in User table" do
    user = User.create!(name:"blah blah", email: @invitation.email, password: "123456", password_confirmation: "123456")
    assert @invitation.replied?
  end

  test "does not resend invitation for replied invite" do
    user = User.create!(name:"blah blah", email: @invitation.email, password: "123456", password_confirmation: "123456")
    
    assert @invitation.replied?
    assert_not @invitation.resend
    assert_equal 0, ActionMailer::Base.deliveries.count
  end

  test "sends email on #resend and resets token" do
    @invitation.save

    assert_not @invitation.replied?
    assert_not @invitation.invite_token.nil?
    old_token = @invitation.invite_token

    @invitation.resend

    assert_not_equal old_token, @invitation.invite_token
    assert_not @invitation.invite_token.empty?
    assert_equal 1, ActionMailer::Base.deliveries.count
  end

  test "last_sent updated" do
    
    
    assert @invitation.last_sent_at.nil?
    @invitation.save
    @invitation.send_invitation_email
    assert_not @invitation.last_sent_at.nil?
    sent_datetime = @invitation.last_sent_at

    @invitation.resend
    assert_not_equal sent_datetime, @invitation.reload.last_sent_at

  end

  test "not_replied returns array of users whos email does not match invitation table" do
    invites_not_replied = Invitation.not_replied
    assert_equal 11, invites_not_replied.count
    invites_not_replied.each do |invite|
      assert_not invite.replied?
    end
  end

  test "invitation has user" do
    invite = invitations(:for_archer)
    assert_not invite.user.nil?
  end

  test "invitation does not have user" do
    @invitation.save
    assert @invitation.user.nil?
  end

end
