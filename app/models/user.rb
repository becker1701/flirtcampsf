class User < Application

	has_secure_password

	attr_accessor :remember_token, :activation_token, :password_reset_token

	validates :name, presence: true, length: { maximum: 50 }
	validates :playa_name, length: { maximum: 50 }
	validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }
	validates :email, format: { with: VALID_EMAIL_REGEX, message: "is not a recognized format." }
	validates :password, length: { minimum: 6 }, allow_blank: true
	validates :phone, length: { maximum: 30 }
	# validate :check_email_existance

	
	before_save :downcase_email
	before_create :generate_activation_digest

	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(self.remember_token))
	end

	def forget
		update_attribute(:remember_digest, nil)
	end

	def activate!
		update_columns(activated: true, activated_at: Time.zone.now)
	end

	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

	def reset_digest_attributes(attribute) #:password_reset or :activation
		send("reset_#{attribute}")
		send("send_#{attribute}_email")
	end

	def send_password_reset_email
		UserMailer.password_reset(self).deliver_now
	end

	def password_reset_expired?
		reset_sent_at < 2.hours.ago
	end

	def blank_password_reset_error
		errors.add(:password, 'can not be blank')
	end

	# def check_email_existance
	# 	if Application.email_exists(self.email)
	# 		errors.add(:email, "has already been taken")
	# 	end
	# end

private



	def generate_activation_digest
		self.activation_token = User.new_token
		self.activation_digest = User.digest(self.activation_token)
	end

	def reset_activation
		self.activation_token = User.new_token
		update_attribute(:activation_digest, User.digest(self.activation_token))
	end

	def reset_password_reset
		self.password_reset_token = User.new_token
		update_columns(reset_digest: User.digest(self.password_reset_token), reset_sent_at: Time.zone.now)
	end

end
