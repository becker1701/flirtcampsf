class TicketMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.ticket_mailer.verify.subject
  #
  def verify(ticket)
    @ticket = ticket

    mail to: ticket.email, subject: "Verify your tickets for sale"
  end
end
