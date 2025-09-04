# frozen_string_literal: true

FactoryBot.define do
  factory :booking_request, class: 'Workflow::BookingRequest' do
    association :accommodation # default accommodation
    status { 'pending' }
    requested_at { Time.current }
    params { { 'start_date' => '2025-09-10', 'end_date' => '2025-09-12', 'guest_name' => 'John Doe' } }

    trait :with_accommodation do
      transient do
        custom_accommodation { nil }
      end

      after(:build) do |booking_request, evaluator|
        booking_request.accommodation ||= evaluator.custom_accommodation || create(:accommodation)
      end
    end
  end
end
