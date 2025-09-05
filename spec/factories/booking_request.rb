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
  factory :workflow_booking_request, class: 'Workflow::BookingRequest' do
    association :accommodation
    status { 'pending' }
    params { { guest_name: 'John Doe', start_date: Date.today.to_s, end_date: (Date.today + 3).to_s } }
    requested_at { Time.current }

    trait :success do
      status { 'success' }
      performed_at { Time.current }
    end

    trait :failed do
      status { 'failed' }
      failure_reason { 'Some failure reason' }
      performed_at { Time.current }
    end
  end
end
