# frozen_string_literal: true

class Hotel < ApplicationRecord
  include HasAmenities
  has_many :rooms, dependent: :destroy

  has_and_belongs_to_many :amenities

  accepts_nested_attributes_for :rooms, allow_destroy: true

  validates :name, presence: true
end
