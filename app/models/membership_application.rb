class MembershipApplication < ActiveRecord::Base



	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

	validates :birth_name, presence: true, length: { maximum: 50 }
	validates :playa_name, length: { maximum: 50 }
	validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }
	validates :email, format: { with: VALID_EMAIL_REGEX, message: "is not a recognized format." }
	validates :phone, length: { maximum: 20 }

	before_save :downcase_email

private
	
	def downcase_email
		self.email.downcase!
	end
end
