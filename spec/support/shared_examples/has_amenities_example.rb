# frozen_string_literal: true

RSpec.shared_examples 'has amenities concern' do
  it 'has a has_and_belongs_to_many association with amenities' do
    association = described_class.reflect_on_association(:amenities)
    expect(association.macro).to eq(:has_and_belongs_to_many)
  end

  it 'responds to amenities_attributes=' do
    expect(described_class.new).to respond_to(:amenities_attributes=)
  end
end
