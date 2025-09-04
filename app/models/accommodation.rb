# frozen_string_literal: true

class Accommodation < ApplicationRecord
  include HasAmenities
  has_many :bookings, dependent: :destroy

  belongs_to :hotel, optional: true

  validates :name, presence: true
  validates :description, presence: true
  validates :location, presence: true
end
