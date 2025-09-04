# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Workflow::BookingRequest, type: :model do
  let(:accommodation) { create(:accommodation) }
  let(:booking) { create(:booking, accommodation: accommodation) }
  let(:booking_request) do
    build(:booking_request, accommodation: accommodation, params: { guest_name: 'John' }, requested_at: Time.current)
  end

  describe 'associations' do
    it { is_expected.to belong_to(:accommodation) }
    it { is_expected.to belong_to(:booking).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:params) }
    it { is_expected.to validate_presence_of(:requested_at) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[pending success failed]) }
  end

  describe '#mark_success' do
    it 'updates the status to success and sets booking_id and performed_at' do
      booking_request.save!
      expect do
        booking_request.mark_success(booking)
      end.to change { booking_request.reload.status }.from('pending').to('success')
                                                     .and change { booking_request.reload.booking_id }.to(booking.id)
                                                                                                      .and change {
                                                                                                             booking_request.reload.performed_at
                                                                                                           }.from(nil)

      expect(booking_request.failure_reason).to be_nil
    end
  end

  describe '#mark_failed' do
    it 'updates the status to failed and sets failure_reason and performed_at' do
      booking_request.save!
      expect do
        booking_request.mark_failed('Some reason')
      end.to change { booking_request.reload.status }.from('pending').to('failed')
                                                     .and change {
                                                            booking_request.reload.failure_reason
                                                          }.to('Some reason')
                                                           .and change {
                                                                  booking_request.reload.performed_at
                                                                }.from(nil)
    end
  end
end
