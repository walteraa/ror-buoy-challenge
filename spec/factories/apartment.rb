# frozen_string_literal: true

FactoryBot.define do
  factory :apartment do
    name        { "Apartment #{SecureRandom.hex(4)}" }
    description { 'Nice and cozy place' }
    price       { 1000 }
    location    { 'City Center' }
    capacity    { 2 }
    address     { '123 Main St' }
  end
end
