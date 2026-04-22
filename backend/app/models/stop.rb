class Stop < ApplicationRecord
  belongs_to :route
  has_many :subscriptions, foreign_key: :pickup_stop_id, dependent: :nullify

  validates :name, presence: true
  validates :lat, :lng, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
