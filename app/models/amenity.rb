# frozen_string_literal: true

class Amenity < ApplicationRecord
  validates :name, uniqueness: true

  has_and_belongs_to_many :accommodations, join_table: 'accommodations_amenities'
end
