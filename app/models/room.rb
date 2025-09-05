# frozen_string_literal: true

class Room < Accommodation
  include HasAmenities
  belongs_to :hotel

  validates :hotel, presence: true
  validates :name, presence: true
  validates :description, presence: true
  validates :location, presence: true
end
