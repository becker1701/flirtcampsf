class User < Application

	has_secure_password

	attr_accessor :remember_token, :activation_token, :password_reset_token

	has_many :intentions, dependent: :destroy
	has_many :activities, dependent: :nullify
	has_many :early_arrivals, dependent: :destroy
	# has_many :events

	validates :name, presence: true, length: { maximum: 50 }
	validates :playa_name, length: { maximum: 50 }
	validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }
	validates :email, format: { with: VALID_EMAIL_REGEX, message: "is not a recognized format." }
	validates :password, length: { minimum: 6 }, allow_blank: true
	validates :phone, length: { maximum: 30 }
	# validate :check_email_existance

	
	before_save :downcase_email
	before_create :generate_activation_digest

	def User.attending_next_event
		joins(:intentions).merge(Intention.for_next_event)
	end

	def User.activated
		where(activated: true).order(:name)
	end

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

	def next_event_intention
		# self.intentions.find_by(event: Event.next_event) 
		event = Event.next_event
		return nil if event.nil?
		self.intentions.find_by(event: event) || event.intentions.build(user: self)

		# self.intentions.for_next_event	
	end

	def assign_ea(event)
		self.early_arrivals.create!(event: event)
	end

	def unassign_ea(event)
		# debugger
		self.early_arrivals.find_by(event: event).destroy
	end

	def ea_exists?(event)
		self.early_arrivals.find_by(event: event)
	end

	# def test_intentions
	# 	Event.next_event.intentions.pluck(:user.id)
	# end



	def User.next_event_intentions

		# self.where(activated: true).includes(:intentions).where('intentions.event_id = ?', Event.next_event.id.to_s).references(:intentions)
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
