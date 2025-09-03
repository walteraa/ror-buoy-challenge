# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe 'associations' do
    it { should belong_to(:accommodation) }
  end

  describe 'validations' do
    it { should validate_presence_of(:guest_name) }
    it { should validate_length_of(:guest_name).is_at_least(2) }
    it { should validate_presence_of(:accommodation_id) }
  end
end
