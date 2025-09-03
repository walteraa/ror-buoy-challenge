# frozen_string_literal: true

class Booking < ApplicationRecord
  belongs_to :accommodation

  validates :guest_name, presence: true, length: { minimum: 2 }
  validates :accommodation_id, presence: true
end
