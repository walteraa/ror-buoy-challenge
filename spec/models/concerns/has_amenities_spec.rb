# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HasAmenities, type: :model do
  let(:accommodation) { create(:accommodation) }

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

  describe 'updating and destroying amenities by id' do
    let!(:amenity) { Amenity.create!(name: 'WiFi') }

    before do
      accommodation.amenities << amenity
    end

    it 'updates an existing amenity when id is provided' do
      accommodation.amenities_attributes = {
        '0' => { 'id' => amenity.id, 'name' => 'Fast WiFi' }
      }

      expect(amenity.reload.name).to eq('Fast WiFi')
      expect(accommodation.amenities).to include(amenity)
    end

    it 'removes an amenity when id and _destroy are provided' do
      expect do
        accommodation.amenities_attributes = {
          '0' => { 'id' => amenity.id, '_destroy' => '1' }
        }
      end.to change { accommodation.amenities.count }.by(-1)

      expect(accommodation.amenities).not_to include(amenity)
    end

    it 'does nothing if the amenity with given id is not found' do
      expect do
        accommodation.amenities_attributes = {
          '0' => { 'id' => 999_999, 'name' => 'Ghost Amenity' }
        }
      end.not_to(change { accommodation.amenities.count })
    end
  end
  describe 'when attributes is neither a Hash nor Array' do
    it 'falls back to empty array and does nothing' do
      expect do
        accommodation.amenities_attributes = 'invalid_input'
      end.not_to(change { Amenity.count })

      expect(accommodation.amenities).to be_empty
    end
  end
end
