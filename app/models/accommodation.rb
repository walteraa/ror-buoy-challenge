# frozen_string_literal: true

class Accommodation < ApplicationRecord
  include HasAmenities
  has_many :bookings, dependent: :destroy

  belongs_to :hotel, optional: true
end
