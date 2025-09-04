# frozen_string_literal: true

FactoryBot.define do
  factory :accommodation do
    name { 'Test Accommodation' }
    price { 100.0 }
    location { 'Test Location' }
    description { 'A nice place' }
  end
end
