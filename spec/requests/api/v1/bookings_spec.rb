# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Bookings', type: :request do
  let!(:accommodation) { create(:accommodation) }
  let!(:bookings) { create_list(:booking, 3, accommodation: accommodation) }
  let(:booking) { bookings.first }

  describe 'GET /api/v1/accommodations/:accommodation_id/bookings' do
    it 'returns all bookings for the accommodation with status 200' do
      get "/api/v1/accommodations/#{accommodation.id}/bookings"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)['bookings']
      expect(body.size).to eq(3)
      expect(body.first.keys).to include('id', 'accommodation_id', 'start_date', 'end_date', 'guest_name')
    end
  end

  describe 'GET /api/v1/bookings/list' do
    it 'returns all bookings with status 200' do
      get '/api/v1/bookings'

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)['bookings']
      expect(body.size).to eq(3)
    end
  end

  describe 'GET /api/v1/bookings/:id' do
    context 'when booking exists' do
      it 'returns the booking with status 200' do
        get "/api/v1/bookings/#{booking.id}"

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)['booking']
        expect(body['id']).to eq(booking.id)
      end
    end

    context 'when booking does not exist' do
      it 'returns 404 not found' do
        get '/api/v1/bookings/invalid_id'

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PATCH /api/v1/bookings/:id' do
    let(:valid_params) { { booking: { guest_name: 'Jane Doe' } } }

    context 'with valid params' do
      it 'updates the booking and returns status 200' do
        patch "/api/v1/bookings/#{booking.id}", params: valid_params

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)['booking']
        expect(body['guest_name']).to eq('Jane Doe')
      end
    end

    context 'with invalid params' do
      it 'returns 422 unprocessable entity' do
        patch "/api/v1/bookings/#{booking.id}", params: { booking: { start_date: nil } }

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body).to be_a(Hash)
      end
    end
  end

  describe 'DELETE /api/v1/bookings/:id' do
    it 'destroys the booking and returns 204 no content' do
      expect do
        delete "/api/v1/bookings/#{booking.id}"
      end.to change(Booking, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
