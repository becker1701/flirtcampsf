class Ticket < Application
  belongs_to :event

  	validate :admission_or_parking_exists
	validates :name, length: { maximum: 50 }
	validates :confirmation_number, length: { maximum: 30 }
	validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }
	validates :email, format: { with: VALID_EMAIL_REGEX, message: "is not a recognized format." }
	
	before_save :downcase_email

	enum status: { for_sale: 1, sold: 2 }

private

	def admission_or_parking_exists
		if admission_qty == 0 && parking_qty == 0
			errors.add(:base, "Admission or Parking quantity has to be greater then 0")
		end
	end
end
