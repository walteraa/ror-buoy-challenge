# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Accommodation, type: :model do
  describe 'associations' do
    it { should have_many(:bookings).dependent(:destroy) }
    it { should belong_to(:hotel).optional }
  end

  describe 'concerns' do
    it 'includes HasAmenities' do
      expect(Hotel.included_modules).to include(HasAmenities)
    end
    it_behaves_like 'has amenities concern'
  end
end
