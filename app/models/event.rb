class Event < ActiveRecord::Base

	has_many :intentions, dependent: :destroy
	has_many :activities, dependent: :destroy
	has_many :early_arrivals, dependent: :destroy
	has_many :tickets, dependent: :nullify
	has_many :payments, dependent: :restrict_with_error

	#TODO: belongs_to :camp_organizer, class_name: :user, foreign_key: :camp_org_id

	scope :event_early_arrivals, ->{ joins(early_arrivals: :user) }

	validates :year, :start_date, :camp_dues, :camp_dues_food, presence: true
	validate :start_date_before_end_date
	validate :early_arrival_date_before_start_date

	def self.next_event
		self.where( "end_date > ?", Date.today ).order(:start_date).limit(1).first
	end

	def days
		(self.start_date..self.end_date).to_a.map! { |day| day.strftime("%a, %b %-e") }
	end

	def date_range
		(self.start_date..self.end_date).to_a
	end

	def extended_date_range
		if self.early_arrival_date && self.end_date
			((self.early_arrival_date - 2.days)..(self.end_date + 2.days)).to_a
		
		elsif self.early_arrival_date.nil? && self.end_date
			((self.start_date - 7.days)..(self.end_date + 2.days)).to_a
		
		elsif self.early_arrival_date.nil? && self.end_date.nil?
			((self.start_date - 3.days)..(self.start_date + 3.days)).to_a
		
		elsif self.early_arrival_date && self.end_date.nil?
			((self.early_arrival_date - 2.days)..(self.start_date + 3.days)).to_a
		
		end
	end

	# def self.early_arrival_list
	# 	joins(early_arrivals: :user).uniq
	# end

	# scope :yurt_owners, -> { joins(:intentions).where(intentions: {yurt_owner: true}) }

	def count_yurts_to_ship
		self.intentions.where(shipping_yurt: true).count(:shipping_yurt)
	end

	def count_yurt_storage_requested
		self.intentions.where(yurt_storage: true).count(:yurt_storage)
	end

	def count_storage_tenants
		self.intentions.where(storage_tenent: true).count(:storage_tenent)
	end

	def sum_storage_dues
		self.intentions.where(storage_tenent: true, yurt_owner: true).sum(:camp_due_storage)
	end

private

	def start_date_before_end_date
		if self.start_date && self.end_date && self.start_date > self.end_date
			errors.add(:start_date, "must be before event end date")
		end
	end

	def early_arrival_date_before_start_date
		if self.start_date && self.early_arrival_date && self.early_arrival_date > self.start_date
			errors.add(:early_arrival_date, "must be before event start date")
		end
	end

end
