# frozen_string_literal: true

module V1
  class ApartmentSerializer < ActiveModel::Serializer
    attributes :id, :name, :description, :price, :location, :capacity, :address, :created_at, :updated_at

    has_many :amenities, serializer: V1::AmenitySerializer
  end
end
