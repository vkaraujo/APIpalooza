# frozen_string_literal: true

class WeatherSnapshot < ApplicationRecord
  validates :city, presence: true
  validates :temperature, presence: true
  validates :condition, presence: true

  scope :recent_for, ->(city) { where(city: city).order(fetched_at: :desc).limit(1) }

  def outdated?
    fetched_at < 24.hours.ago
  end
end
