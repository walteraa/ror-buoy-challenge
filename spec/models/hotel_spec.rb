# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hotel, type: :model do
  describe 'associations' do
    it { should have_many(:rooms).dependent(:destroy) }
  end

  describe 'concerns' do
    it 'includes HasAmenities' do
      expect(Hotel.included_modules).to include(HasAmenities)
    end
    it_behaves_like 'has amenities concern'
  end
end
