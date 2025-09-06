# frozen_string_literal: true

class AccommodationSerializer < ActiveModel::Serializer
  type :accomodation
  attributes :id, :name, :description, :price, :location, :type
end
