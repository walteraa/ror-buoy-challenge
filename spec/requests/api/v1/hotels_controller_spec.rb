# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::HotelsController, type: :request do
  let!(:hotels) { create_list(:hotel, 3) }
  let(:hotel)   { hotels.first }

  describe 'GET /api/v1/hotels' do
    it 'returns paginated hotels with status 200' do
      get '/api/v1/hotels'

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body).to have_key('hotels')
      expect(body['hotels'].size).to eq(3)
      expect(body).to have_key('meta')
      expect(body['meta']).to include('current_page', 'total_pages', 'total_count')
    end
  end

  describe 'GET /api/v1/hotels/:id' do
    context 'when hotel exists' do
      it 'returns the hotel with status 200' do
        get "/api/v1/hotels/#{hotel.id}"

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body.dig('hotel', 'name')).to eq(hotel.name)
      end
    end

    context 'when hotel does not exist' do
      it 'returns 404 not found' do
        get '/api/v1/hotels/0'

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/hotels' do
    let(:valid_params) do
      {
        hotel: {
          name: 'New Hotel',
          address: '123 Street',
          amenities_attributes: [{ name: 'Pool' }]
        }
      }
    end

    let(:invalid_params) do
      {
        hotel: {
          name: '',
          address: ''
        }
      }
    end

    context 'with valid params' do
      it 'creates a hotel and returns status 201' do
        expect do
          post '/api/v1/hotels', params: valid_params
        end.to change(Hotel, :count).by(1)

        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body.dig('hotel', 'name')).to eq('New Hotel')
      end
    end

    context 'with invalid params' do
      it 'returns 422 unprocessable entity' do
        post '/api/v1/hotels', params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body).to have_key('errors')
      end
    end
  end

  describe 'PATCH /api/v1/hotels/:id' do
    let(:valid_update) { { hotel: { name: 'Updated Name' } } }
    let(:invalid_update) { { hotel: { name: '' } } }

    context 'with valid params' do
      it 'updates the hotel and returns status 200' do
        patch "/api/v1/hotels/#{hotel.id}", params: valid_update

        expect(response).to have_http_status(:ok)
        expect(hotel.reload.name).to eq('Updated Name')
      end
    end

    context 'with invalid params' do
      it 'returns 422 unprocessable entity' do
        patch "/api/v1/hotels/#{hotel.id}", params: invalid_update

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body).to have_key('errors')
      end
    end
  end

  describe 'DELETE /api/v1/hotels/:id' do
    it 'destroys the hotel and returns 204' do
      expect do
        delete "/api/v1/hotels/#{hotel.id}"
      end.to change(Hotel, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
