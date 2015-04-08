class UserNote < ActiveRecord::Base
  belongs_to :user

  validates :user_id, :note, presence: true
  validates :note, length: { maximum: 1000 }
end
