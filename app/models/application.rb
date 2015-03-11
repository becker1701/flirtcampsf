class Application < ActiveRecord::Base
	self.abstract_class = true


	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i


	#returns the hash digest of the given string
	# In order to create the fixtures, I need to save the fixture with the password_digest that BCrypt calculates
	def self.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
	end

	def self.new_token
		SecureRandom::urlsafe_base64
	end

	def downcase_email
		self.email.downcase!
	end

	def authenticated?(attribute, token)
		digest = send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)
	end	


	# def self.email_exists(email = nil)
	# 	return false if email.nil?

	# 	#first, lookup email in the User table
	# 	found_record = User.find_by(email: email)
	# 	return found_record unless found_record.nil?

	# 	#then, lookup email in the Invitation table
	# 	found_record = Invitation.find_by(email: email)
	# 	return found_record unless found_record.nil?		

	# 	#finally, lookup email in the Membership Application table
	# 	found_record = MembershipApplication.find_by(email: email)
	# 	return found_record unless found_record.nil?

	# 	return false if found_record.nil?

	# end


end