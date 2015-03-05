class User < ActiveRecord::Base

	has_secure_password

	attr_accessor :remember_token, :activation_token, :password_reset_token

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

	validates :name, :playa_name, presence: true, length: { maximum: 50 }
	validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }
	validates :email, format: { with: VALID_EMAIL_REGEX, message: "is not a recognized format." }
	validates :password, length: { minimum: 6 }, allow_blank: true
	validates :phone, length: { maximum: 20 }

	
	before_save :downcase_email
	before_create :generate_activation_digest


	#returns the hash digest of the given string
	# In order to create the fixtures, I need to save the fixture with the password_digest that BCrypt calculates
	def self.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
	end

	def self.new_token
		SecureRandom::urlsafe_base64
	end

	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(self.remember_token))
	end

	def forget
		update_attribute(:remember_digest, nil)
	end

	def authenticated?(attribute, token)
		digest = send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)
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

	# def reset_activation_digest
	# 	debugger
	# 	generate_activation_digest if self.activation_token.nil?
	# end

private
	
	def downcase_email
		self.email.downcase!
	end

	# def generate_token(attribute)
	# 	token = send("#{attribute}_token")
	# 	token = User.new_token
	# end

	def generate_activation_digest
		self.activation_token = User.new_token
		# generate_token(:activation)
		self.activation_digest = User.digest(self.activation_token)
	end

	def reset_activation
		self.activation_token = User.new_token
		# generate_token(:activation)
		update_attribute(:activation_digest, User.digest(self.activation_token))
	end

	def reset_password_reset
		self.password_reset_token = User.new_token
		# generate_token(:password_reset)
		update_columns(reset_digest: User.digest(self.password_reset_token), reset_sent_at: Time.zone.now)
	end

end
