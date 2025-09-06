# frozen_string_literal: true

class AccommodationSerializer < ActiveModel::Serializer
  type :accommodation
  attributes :id, :name, :description, :price, :location, :type
end
