class MembershipApplication < Application

  has_one :invitation
  has_one :user

  validates :name, presence: true, length: { maximum: 50 }
  validates :playa_name, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }
  validates :email, format: { with: VALID_EMAIL_REGEX, message: "is not a recognized format." }
  validates :phone, length: { maximum: 30 }

  before_save :downcase_email

  scope :not_approved, -> { where(approved: false) }

  def approve
    update_attribute(:approved, true)

    invite = Invitation.create!(
      name: self.name, email: self.email, membership_application: self
    )

    invite.send_invitation_email
  end

  def decline
    update_attribute(:approved, false)
    send_declined_email
  end


  def send_declined_email
    MembershipApplicationsMailer.declined(self).deliver_now
  end

  def archive!
    update_attribute(:archived, true)
  end

private


end
