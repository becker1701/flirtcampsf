class Event < ActiveRecord::Base

	has_many :intentions, dependent: :destroy
	# belongs_to :camp_organizer, class_name: :user, foreign_key: :camp_org_id

	validates :year, presence: true

	def self.next_event
		self.where( "end_date > ?", Date.today ).first
	end

end
