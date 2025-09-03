# frozen_string_literal: true

class Hotel < ApplicationRecord
  include HasAmenities
  has_many :rooms, dependent: :destroy

  has_and_belongs_to_many :amenities
end
