# Preview all emails at http://localhost:3000/rails/mailers/ticket_mailer
class TicketMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/ticket_mailer/verify
  def verify
  	@ticket = Ticket.first
  	@ticket.verification_token = Ticket.new_token
    TicketMailer.verify(@ticket)
  end

end
