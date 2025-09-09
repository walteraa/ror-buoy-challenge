# frozen_string_literal: true

require "rails_helper"

RSpec.describe ComputeNextAvailability do
  let(:from_date) { Date.new(2025, 1, 1) }

  describe ".call" do
    subject { described_class.call(from_date, bookings) }

    context "when there are no bookings" do
      let(:bookings) { [] }

      it "returns the from_date directly" do
        expect(subject).to eq(from_date)
      end
    end

    context "when there is a gap before the first booking" do
      let(:bookings) do
        [
          create(:booking, start_date: Date.new(2025, 1, 5), end_date: Date.new(2025, 1, 7))
        ]
      end

      it "returns availability from from_date to the day before booking.start_date" do
        expect(subject).to eq(
          { "from" => from_date, "to" => Date.new(2025, 1, 4) }
        )
      end
    end

    context "when bookings are continuous with no gaps" do
      let(:bookings) do
        [
          create(:booking, start_date: Date.new(2025, 1, 1), end_date: Date.new(2025, 1, 3)),
          create(:booking, start_date: Date.new(2025, 1, 4), end_date: Date.new(2025, 1, 6))
        ]
      end

      it "returns availability starting after the last booking with to = nil" do
        expect(subject).to eq(
          { "from" => Date.new(2025, 1, 7), "to" => nil }
        )
      end
    end

    context "when bookings overlap" do
      let(:bookings) do
        [
          create(:booking, start_date: Date.new(2025, 1, 1), end_date: Date.new(2025, 1, 5)),
          create(:booking, start_date: Date.new(2025, 1, 3), end_date: Date.new(2025, 1, 10))
        ]
      end

      it "uses the max end_date correctly" do
        expect(subject).to eq(
          { "from" => Date.new(2025, 1, 11), "to" => nil }
        )
      end
    end

    context "when from_date is inside an existing booking" do
      let(:bookings) do
        [
          create(:booking, start_date: Date.new(2024, 12, 30), end_date: Date.new(2025, 1, 3))
        ]
      end

      it "moves current_date to after the booking" do
        expect(subject).to eq(
          { "from" => Date.new(2025, 1, 4), "to" => nil }
        )
      end
    end
  end
end
