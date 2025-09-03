# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HasAmenities, type: :model do
  let(:accommodation) { Accommodation.create! }

  describe '#amenities_attributes=' do
    it 'creates a new amenity if it does not exist' do
      expect do
        accommodation.amenities_attributes = { '0' => { 'name' => 'Balcony' } }
      end.to change { Amenity.count }.by(1)

      expect(accommodation.amenities.map(&:name)).to include('Balcony')
    end

    it 'reuses existing amenity if name already exists' do
      amenity = Amenity.create!(name: 'Parking')

      expect do
        accommodation.amenities_attributes = { '0' => { 'name' => 'Parking' } }
      end.not_to(change { Amenity.count })

      expect(accommodation.amenities).to include(amenity)
    end

    it 'ignores blank amenity names' do
      expect do
        accommodation.amenities_attributes = { '0' => { 'name' => '' } }
      end.not_to(change { Amenity.count })
    end
  end
end
