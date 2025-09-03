# frozen_string_literal: true

module HasAmenities
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :amenities
    accepts_nested_attributes_for :amenities
  end

  def amenities_attributes=(attrs)
    attrs.each_value do |amenity_attr|
      next if amenity_attr['name'].blank?

      amenity = Amenity.find_or_create_by(name: amenity_attr['name'])
      amenities << amenity unless amenities.include?(amenity)
    end
  end
end
