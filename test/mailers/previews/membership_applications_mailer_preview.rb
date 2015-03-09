# Preview all emails at http://localhost:3000/rails/mailers/membership_applications_mailer
class MembershipApplicationsMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/membership_applications_mailer/organizer_notification
  def organizer_notification
    @membership_app = MembershipApplication.first
    MembershipApplicationsMailer.organizer_notification(@membership_app)
  end

  # Preview this email at http://localhost:3000/rails/mailers/membership_applications_mailer/thank_you
  def thank_you
  	@membership_app = MembershipApplication.first
    MembershipApplicationsMailer.thank_you(@membership_app)
  end

end
