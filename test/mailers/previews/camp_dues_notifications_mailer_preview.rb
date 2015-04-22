# Preview all emails at http://localhost:3000/rails/mailers/camp_dues_notifications
class CampDuesNotificationsMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/camp_dues_notifications/camp_dues_notification
  def camp_dues_notification
  	user = User.first
    CampDuesNotificationsMailer.camp_dues_notification(user)
  end

end
