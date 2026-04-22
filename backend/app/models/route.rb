class Route < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :stops, -> { order(:position) }, dependent: :destroy
  has_many :schedules, dependent: :destroy
  has_many :rides, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  validates :name, presence: true
  validates :school_name, presence: true
  validates :visibility, inclusion: { in: %w[public private invite_only] }

  scope :active, -> { where(active: true) }
  scope :publicly_visible, -> { where(visibility: "public") }
end
