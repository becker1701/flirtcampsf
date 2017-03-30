class MembershipApplicationsMailer < ApplicationMailer

  helper :membership_applications

  def organizer_notification(membership_app)
    @membership_app = membership_app
    mail to: "campmaster@flirtcampsf.com", subject: "A new Flirt Camp Member Application has been submitted!"
  end


  def thank_you(membership_app)
    @membership_app = membership_app
    mail to: @membership_app.email, subject: "Thank you for your application to Flirt Camp!"
  end



  def declined(membership_app)
    @membership_app = membership_app
    mail to: @membership_app.email, subject: "Your Flirt Camp application."
  end
end
