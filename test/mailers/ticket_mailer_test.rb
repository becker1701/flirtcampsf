require 'test_helper'

class TicketMailerTest < ActionMailer::TestCase
  
	def setup
		@ticket = tickets(:one)
	end


  test "verify" do

  	@ticket.verification_token = Ticket.new_token

    mail = TicketMailer.verify(@ticket)
    assert_equal "Verify your tickets for sale", mail.subject
    assert_equal ["#{@ticket.email}"], mail.to
    assert_equal ["no-reply@flirtcampsf.com"], mail.from
    
    assert_match "ticket_id=#{@ticket.id}", mail.body.encoded
    assert_match @ticket.name, mail.body.encoded
    assert_match @ticket.verification_token, mail.body.encoded
    assert_match CGI.escape(@ticket.email), mail.body.encoded

  end

end
