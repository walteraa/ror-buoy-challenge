# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apartment, type: :model do
  describe 'concerns' do
    it 'includes HasAmenities' do
      expect(Apartment.included_modules).to include(HasAmenities)
    end
  end
end
