class LocationPing < ApplicationRecord
  belongs_to :ride
  belongs_to :user

  validates :lat, :lng, :recorded_at, presence: true

  # Haversine distance in metres between two lat/lng points
  def self.distance_metres(lat1, lng1, lat2, lng2)
    rad = Math::PI / 180
    dlat = (lat2 - lat1) * rad
    dlng = (lng2 - lng1) * rad
    a = Math.sin(dlat / 2)**2 +
        Math.cos(lat1 * rad) * Math.cos(lat2 * rad) * Math.sin(dlng / 2)**2
    6_371_000 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  end
end
