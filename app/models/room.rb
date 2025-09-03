# frozen_string_literal: true

class Room < Accommodation
  include HasAmenities
  belongs_to :hotel

  validates :hotel, presence: true
end
