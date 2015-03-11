require 'test_helper'

class MembershipApplicationsMailerTest < ActionMailer::TestCase

  # include MembershipApplicationsHelper

  def setup
    @membership_app = membership_applications(:first)
  end

  test "organizer_notification" do
    mail = MembershipApplicationsMailer.organizer_notification(@membership_app)

    assert_equal "A new Flirt Camp Member Application has been submitted!", mail.subject
    assert_equal ["campmaster@flirtcampsf.com"], mail.to
    assert_equal ["no-reply@flirtcampsf.com"], mail.from

    assert_match @membership_app.birth_name, mail.body.encoded
    assert_match @membership_app.email, mail.body.encoded

  end

  test "thank_you" do
    mail = MembershipApplicationsMailer.thank_you(@membership_app)

    assert_equal "Thank you for your submission to Flirt Camp!", mail.subject
    assert_equal [@membership_app.email], mail.to
    assert_equal ["no-reply@flirtcampsf.com"], mail.from
    
    assert_match @membership_app.birth_name, mail.body.encoded
    assert_match @membership_app.playa_name, mail.body.encoded
    assert_match @membership_app.email, mail.body.encoded
    assert_match @membership_app.phone, mail.body.encoded
    assert_match @membership_app.home_town, mail.body.encoded
    assert_match @membership_app.years_at_bm.to_s, mail.body.encoded
    assert_match @membership_app.possibility, mail.body.encoded
    assert_match @membership_app.contribution, mail.body.encoded
    assert_match @membership_app.passions, mail.body.encoded
  
  end


  test "approve" do
    invitation = Invitation.create!(name: @membership_app.birth_name, email: @membership_app.email)
    assert_not_nil invitation.invite_token

    mail = InvitationMailer.invite(invitation)
    assert_equal "You have been invited to Flirt Camp!", mail.subject
    assert_equal [@membership_app.email], mail.to
    assert_equal ["campmaster@flirtcampsf.com"], mail.from
    # assert_match display_name(@membership_app), mail.body.encoded
  end


test "decline" do
    mail = MembershipApplicationsMailer.declined(@membership_app)
    assert_equal "Your Flirt Camp application has been declined.", mail.subject
    assert_equal [@membership_app.email], mail.to
    assert_equal ["no-reply@flirtcampsf.com"], mail.from
    # assert_match display_name(@membership_app), mail.body.encoded
  
  end
end
