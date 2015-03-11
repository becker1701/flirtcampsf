class MembershipApplication < Application


	validates :birth_name, presence: true, length: { maximum: 50 }
	validates :playa_name, length: { maximum: 50 }
	validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }
	validates :email, format: { with: VALID_EMAIL_REGEX, message: "is not a recognized format." }
	validates :phone, length: { maximum: 30 }

	before_save :downcase_email

	scope :not_approved, -> { where(approved: false) }

	def approve
		update_attribute(:approved, true)
		invite = Invitation.create!(name: self.birth_name, email: self.email)
		invite.send_invitation_email
		
	end

	def decline
		update_attribute(:approved, false)
		send_declined_email
	end


	def send_declined_email
		MembershipApplicationsMailer.declined(self).deliver_now
	end

private
	

end
