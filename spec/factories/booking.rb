# frozen_string_literal: true

FactoryBot.define do
  factory :booking do
    association :accommodation
    sequence(:start_date) { |n| Date.today + (n * 3).days }
    sequence(:end_date)   { |n| Date.today + (n * 3).days + 2.days }
    guest_name { 'John Doe' }
  end
end
