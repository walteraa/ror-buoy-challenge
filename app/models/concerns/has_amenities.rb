# frozen_string_literal: true

module HasAmenities
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :amenities
    accepts_nested_attributes_for :amenities, allow_destroy: true
  end

  def amenities_attributes=(attributes)
    amenity_attrs = case attributes
                    when Array then attributes
                    when Hash  then attributes.values
                    else []
                    end

    current_amenity_names = amenities.pluck(:name)

    amenity_attrs.each do |raw_attr|
      amenity_attr = raw_attr.with_indifferent_access

      if amenity_attr[:id].present?
        amenity = amenities.find_by(id: amenity_attr[:id])
        next unless amenity

        if amenity_attr[:_destroy]
          amenities.destroy(amenity)
        else
          amenity.update(amenity_attr.except(:id, :_destroy))
        end
      else
        name = amenity_attr[:name].to_s.strip
        next if name.blank? || current_amenity_names.include?(name)

        # Reuse if exists, otherwise create
        amenity = Amenity.find_or_create_by!(name: name)

        amenities << amenity unless amenities.exists?(id: amenity.id)
        current_amenity_names << name
      end
    end
  end
end
