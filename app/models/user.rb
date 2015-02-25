class User < ActiveRecord::Base

	has_secure_password

	attr_accessor :remember_token

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

	validates :name, presence: true, length: { maximum: 50 }
	validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }
	validates :email, format: { with: VALID_EMAIL_REGEX, message: "is not a recognized format." }
	validates :password, length: { minimum: 6 }, allow_blank: true
	
	before_save { self.email.downcase! }


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

	def authenticated?(remember_token)
		return false if self.remember_digest.nil?
		BCrypt::Password.new(self.remember_digest).is_password?(remember_token) 
	end

end
