class Schedule < ApplicationRecord
  belongs_to :route
  has_many :rides, dependent: :nullify

  validates :start_time, presence: true
  validates :timezone, presence: true
  validates :days_of_week, presence: true
end
