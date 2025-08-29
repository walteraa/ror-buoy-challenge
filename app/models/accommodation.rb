class Accommodation < ApplicationRecord
  has_many :bookings, dependent: :destroy
end
