# frozen_string_literal: true

FactoryBot.define do
  factory :hotel do
    name    { "Test Hotel #{SecureRandom.hex(4)}" }
    address { '123 Test Street' }
  end
end
