# frozen_string_literal: true

module V1
  class HotelSerializer < ActiveModel::Serializer
    attributes :id, :name, :address, :created_at, :updated_at

    has_many :amenities, serializer: V1::AmenitySerializer
  end
end
