# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::AccommodationsController, type: :request do
  let!(:accommodations) { create_list(:accommodation, 3) }
  let(:accommodation)   { accommodations.first }

  describe 'GET /api/v1/accommodations' do
    it 'returns paginated accommodations with status 200' do
      get '/api/v1/accommodations'

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to have_key('accommodations')
      expect(body['accommodations'].size).to eq(3)
      expect(body).to have_key('meta')
      expect(body['meta']).to include('current_page', 'total_pages', 'total_count')
    end
  end

  describe 'GET /api/v1/accommodations/:id' do
    context 'when accommodation exists' do
      it 'returns the accommodation with status 200' do
        get "/api/v1/accommodations/#{accommodation.id}"

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body.dig('accommodation', 'name')).to eq(accommodation.name)
      end
    end

    context 'when accommodation does not exist' do
      it 'returns 404 not found' do
        get '/api/v1/accommodations/0'

        expect(response).to have_http_status(:not_found)
      end
    end
  end
  describe 'POST /api/v1/accommodations/:id/book' do
    let(:valid_params) do
      {
        start_date: '2025-09-10',
        end_date: '2025-09-12',
        guest_name: 'John Doe'
      }
    end

    context 'with valid booking params' do
      it 'creates a booking request, enqueues the job, and returns 202' do
        expect do
          post "/api/v1/accommodations/#{accommodation.id}/book", params: valid_params
        end.to change(Workflow::BookingRequest, :count).by(1)

        expect(response).to have_http_status(:accepted)
        body = JSON.parse(response.body)
        expect(body).to include('message', 'booking_request_id')
      end
    end

    context 'with invalid accommodation id' do
      it 'returns 404 not found' do
        post '/api/v1/accommodations/0/book', params: valid_params
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when booking creation fails' do
      before do
        allow(Workflow::BookingRequest).to receive(:create!).and_raise(StandardError, 'Unexpected failure')
      end

      it 'returns 422 unprocessable entity with error message' do
        post "/api/v1/accommodations/#{accommodation.id}/book", params: valid_params

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body).to include('error' => 'Unexpected failure')
      end
    end
  end
end
