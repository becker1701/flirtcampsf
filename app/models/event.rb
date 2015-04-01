class Event < ActiveRecord::Base

	has_many :intentions, dependent: :destroy
	has_many :activities, dependent: :destroy
	has_many :early_arrivals, dependent: :destroy
	has_many :tickets, dependent: :nullify

	#TODO: belongs_to :camp_organizer, class_name: :user, foreign_key: :camp_org_id

	validates :year, presence: true
	validate :start_date_before_end_date
	validate :early_arrival_date_before_start_date

	def self.next_event
		self.where( "end_date > ?", Date.today ).first
	end

	def days
		(self.start_date..self.end_date).to_a.map! { |day| day.strftime("%a, %b %-e") }
	end

	def date_range
		(self.start_date..self.end_date).to_a
	end

	def extended_date_range
		((self.early_arrival_date - 2.days)..(self.end_date + 2.days)).to_a
	end

	def early_arrival_list
		self.early_arrivals.includes(:user)
	end

private

	def start_date_before_end_date
		if self.end_date && self.start_date > self.end_date
			errors.add(:start_date, "must be before event end date")
		end
	end

	def early_arrival_date_before_start_date
		if self.start_date && self.early_arrival_date > self.start_date
			errors.add(:early_arrival_date, "must be before event start date")
		end
	end

end
