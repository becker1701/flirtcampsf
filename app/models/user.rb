class User < Application

  has_secure_password

  attr_accessor :remember_token, :activation_token, :password_reset_token



  has_many :intentions, dependent: :destroy
  has_many :activities, dependent: :nullify
  has_many :early_arrivals, dependent: :destroy
  has_many :user_notes, dependent: :destroy
  has_many :payments, dependent: :restrict_with_error

  belongs_to :membership_application
  belongs_to :invitation, primary_key: :email


  has_one :next_event_intention, ->{ where(event: Event.next_event) }, class_name: 'Intention'
  has_one :next_event_early_arrival, ->{ where(event: Event.next_event) }, class_name: 'EarlyArrival'

  default_scope -> { includes(:next_event_intention, :next_event_early_arrival) }

  validates :name, presence: true, length: { maximum: 50 }
  validates :playa_name, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }
  validates :email, format: { with: VALID_EMAIL_REGEX, message: "is not a recognized format." }
  validates :password, length: { minimum: 6 }, allow_blank: true
  validates :phone, length: { maximum: 30 }


  before_save :downcase_email
  before_create :generate_activation_digest

  def User.next_event_camp_dues
    next_event_camp_dues = 0
    # binding.pry
    User.attending_next_event.each do |u|
      next_event_camp_dues += u.sum_camp_dues
    end

    next_event_camp_dues
  end

  def User.next_event_payments
    Payment.where(event: Event.next_event).sum(:amount)
  end

  def User.next_event_balance
    User.next_event_camp_dues - User.next_event_payments
  end

  def first_name
    name.split(" ")[0]
  end

  def User.attending_next_event
    joins(:intentions).merge(Intention.going_to_next_event)
  end

  def User.not_attending_next_event
    joins(:intentions).merge(Intention.not_going_to_next_event)
  end

  def User.not_responded_to_next_event
    where(intentions: {id: nil})
  end

  def User.has_ticket_to_next_event
    where(intentions: {status: [1,3]})
  end

  def User.needs_ticket_to_next_event
    where(intentions: {status: 2})
  end

  def User.driving_to_next_event
    where(intentions: {transportation: 1})
  end

  def User.early_arrivals_next_event
    joins(:next_event_early_arrival)
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

  def camp_dues
    if self.next_event_intention && self.next_event_intention.going?
      Event.next_event.camp_dues
    else
      0
    end
  end

  def camp_dues_food
    if self.next_event_intention && self.next_event_intention.going? && self.next_event_intention.opt_in_meals?
      Event.next_event.camp_dues_food
    else
      0
    end
  end

  def camp_dues_storage
    if self.next_event_intention && self.next_event_intention.going? && self.next_event_intention.storage_tenent?
      self.next_event_intention.storage_amount_due
    else
      0
    end
  end

  def sum_camp_dues
    sum_dues = 0
    sum_dues = self.camp_dues + self.camp_dues_food + self.camp_dues_storage
  end

  def sum_next_event_payments
    self.payments.where(event: Event.next_event).sum(:amount)
  end

  def next_event_camp_dues_balance
    if next_event_intention.nil?
      0
    else
      self.sum_camp_dues - self.sum_next_event_payments
    end
  end

  # def next_event_intention

  #   # event = Event.next_event
  #   # return nil if event.nil?
  #   # self.intentions.find_by(event: event) || event.intentions.build(user: self)

  #   # self.includes(:intentions).merge(Intention.where(event: Event.next_event)).references(:intentions)
  #   intentions.for_next_event

  # end

  # def next_event_intentions
  # scope :next_event_intentions, -> {joins(:intentions).where(intention: {event: Event.next_event}).references(:intentions)}
  # end

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

  def ea_info(event)
    self.early_arrivals.find_by(event: event)
  end

  # def User.next_event_intentions
  #   #TODO: test next_event_intentions
  #   self.activated.includes(:intentions).merge(Intention.for_next_event).references(:intentions)
  # end


  def send_camp_dues_notification
    CampDuesNotificationsMailer.camp_dues_notification(self).deliver_now
    self.next_event_intention.update_attribute(:dues_last_sent, DateTime.now)
  end

  def self.to_csv
    CSV.generate do |csv|
      columns_to_export = %w[name playa_name phone email]

      csv << columns_to_export
      all.each do |user|
        csv << user.attributes.values_at(*columns_to_export)
      end
    end
  end


  def self.dietary_to_csv

    user_list = User.attending_next_event

    CSV.generate do |csv|
      columns_to_export = %w[name playa_name food_restrictions]

      csv << columns_to_export
      user_list.each do |user|
        csv << [user.name, user.playa_name, user.intentions.for_next_event.first.food_restrictions]
      end
    end

  end



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
