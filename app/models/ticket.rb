class Ticket < Application
  belongs_to :event

  	attr_accessor :verification_token

  	validate :admission_or_parking_exists
	validates :name, length: { maximum: 50 }
	validates :confirmation_number, length: { maximum: 30 }
	validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }
	validates :email, format: { with: VALID_EMAIL_REGEX, message: "is not a recognized format." }
	
	before_save :downcase_email
	before_create :generate_verification_digest

	enum status: { for_sale: 1, sold: 2 }

	def send_verification_email
		TicketMailer.verify(self).deliver_now
	end

	def verified!
		update_columns(verified: true, verified_at: Time.zone.now)
	end

	def Ticket.verified
		where(verified: true)
	end

private

	def admission_or_parking_exists
		if admission_qty == 0 && parking_qty == 0
			errors.add(:base, "Admission or Parking quantity has to be greater then 0")
		end
	end

	def generate_verification_digest
		self.verification_token = Ticket.new_token
		self.verification_digest = Ticket.digest(self.verification_token)
	end

end
