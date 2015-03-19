class Event < ActiveRecord::Base

	has_many :intentions

	validates :year, presence: true

	def self.next_event
		self.where( "end_date > ?", Date.today ).first
	end

end