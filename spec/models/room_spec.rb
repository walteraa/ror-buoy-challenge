# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Room, type: :model do
  describe 'associations' do
    it { should belong_to(:hotel) }
  end

  describe 'validations' do
    it { should validate_presence_of(:hotel) }
  end

  describe 'concerns' do
    it 'includes HasAmenities' do
      expect(Room.included_modules).to include(HasAmenities)
    end
    it_behaves_like 'has amenities concern'
  end
end
