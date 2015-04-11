class Invitation < Application

	attr_accessor :invite_token
	
	default_scope -> { includes(:user) }

	belongs_to :user, foreign_key: :email, primary_key: :email

	validates :name, presence: true
	validates :email, presence: true, uniqueness: { case_sensitive: false }
	validates :email, format: { with: VALID_EMAIL_REGEX, message: "is not a recognized format." }

	before_save :downcase_email
	before_create :generate_invite_token


	def send_invitation_email
		self.update_attribute(:last_sent_at, Time.zone.now)
		InvitationMailer.invite(self).deliver_now
	end

	def self.not_replied
		includes(:user).merge(User.unscoped.where(id: nil)).references(:users)
		# merge(User.where(id: nil)).references(:users)
	end

	def self.all_replied
		joins(:user)
	end

	def replied?
		user
		
	end

	def resend
		return false if replied? 
		self.invite_token = Invitation.new_token
		self.invite_digest = Invitation.digest(self.invite_token)
		# debugger
		self.save
		self.send_invitation_email
	end

private


	def generate_invite_token
		self.invite_token = Invitation.new_token
		self.invite_digest = Invitation.digest(self.invite_token)
	end

end
