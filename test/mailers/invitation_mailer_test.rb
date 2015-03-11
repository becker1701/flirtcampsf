require 'test_helper'

class InvitationMailerTest < ActionMailer::TestCase
  test "invite" do

  	invitation = invitations(:one)
  	invitation.invite_token = 'invite_012345'

    mail = InvitationMailer.invite(invitation)
    assert_equal "You have been invited to Flirt Camp!", mail.subject
    assert_equal [invitation.email], mail.to
    assert_equal ["campmaster@flirtcampsf.com"], mail.from
    # debugger
    assert_match invitation.invite_token, mail.body.encoded
    assert_match CGI::escape(invitation.email), mail.body.encoded
    # assert_match edit_invitation_url, mail.body.encoded
  end

end
