class Invitation < Application

	attr_accessor :invite_token
	
	validates :name, presence: true
	validates :email, presence: true, uniqueness: { case_sensitive: false }
	validates :email, format: { with: VALID_EMAIL_REGEX, message: "is not a recognized format." }

	before_save :downcase_email
	before_create :generate_invite_token


	def send_invitation_email
		InvitationMailer.invite(self).deliver_now
	end

	
private


	def generate_invite_token
		self.invite_token = Invitation.new_token
		self.invite_digest = Invitation.digest(self.invite_token)
	end

end
