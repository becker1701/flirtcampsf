class CampDuesNotificationsMailer < ApplicationMailer

  helper :membership_applications

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.camp_dues_notifications.camp_dues_notification.subject
  #
  def camp_dues_notification(user)
  	@user = user
  	@event = Event.next_event

    mail to: @user.email, subject: "Flirt Camp - Camp Dues!!", from: "campmaster@flirtcampsf.com"
  end
end
