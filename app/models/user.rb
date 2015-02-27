class User < ActiveRecord::Base

	has_secure_password

	attr_accessor :remember_token, :activation_token, :password_reset_token

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

	validates :name, presence: true, length: { maximum: 50 }
	validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }
	validates :email, format: { with: VALID_EMAIL_REGEX, message: "is not a recognized format." }
	validates :password, length: { minimum: 6 }, allow_blank: true
	
	before_save :downcase_email
	before_create :create_activation_digest


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
		update_attribute(:activated, true)
		update_attribute(:activated_at, Time.zone.now)
	end

	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

	def reset_password
		self.password_reset_token = User.new_token
		update_attribute(:reset_digest, User.digest(self.password_reset_token))
		update_attribute(:reset_sent_at, Time.zone.now)
		send_password_reset_email
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

private
	
	def downcase_email
		self.email.downcase!
	end

	def create_activation_digest
		self.activation_token = User.new_token
		self.activation_digest = User.digest(self.activation_token)
	end

end
