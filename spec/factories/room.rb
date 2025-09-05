# frozen_string_literal: true

# spec/factories/rooms.rb
FactoryBot.define do
  factory :room do
    association :hotel
    name { 'Deluxe Suite' }
    description { 'Spacious room with sea view' }
    price { 200.0 }
    location { 'Ocean Wing' }
    capacity { 4 }
    address { '123 Beach Ave' }

    transient do
      amenities_count { 2 }
    end

    after(:create) do |room, evaluator|
      create_list(:amenity, evaluator.amenities_count, rooms: [room]) if room.amenities.empty?
    end
  end
end
