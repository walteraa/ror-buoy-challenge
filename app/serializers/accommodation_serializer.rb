# frozen_string_literal: true

class AccommodationSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :price, :location, :type
end
