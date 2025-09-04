# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Hotels::Rooms', type: :request do
  let!(:hotel) { Hotel.create!(name: 'Test Hotel') }
  let!(:amenity1) { Amenity.create!(name: 'WiFi') }
  let!(:amenity2) { Amenity.create!(name: 'Air Conditioning') }

  let!(:room) do
    hotel.rooms.create!(
      name: 'Deluxe Suite',
      description: 'Spacious room with sea view',
      price: 200,
      location: 'Ocean Wing',
      capacity: 4,
      address: '123 Beach Ave',
      amenities: [amenity1, amenity2]
    )
  end

  describe 'GET /hotels/:hotel_id/rooms' do
    it 'returns paginated rooms with amenities' do
      get "/api/v1/hotels/#{hotel.id}/rooms", params: { page: 1, per_page: 10 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['rooms'].size).to eq(1)
      expect(json['rooms'].first['name']).to eq(room.name)
      expect(json['rooms'].first['amenities'].map { |a| a['name'] }).to include('WiFi', 'Air Conditioning')
      expect(json['meta']).to include('current_page', 'total_pages', 'total_count')
    end

    it 'returns 404 if hotel does not exist' do
      get '/api/v1/hotels/0/rooms'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /hotels/:hotel_id/rooms/:id' do
    it 'returns a single room with amenities' do
      get "/api/v1/hotels/#{hotel.id}/rooms/#{room.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['room']['name']).to eq(room.name)
      expect(json['room']['amenities'].map { |a| a['name'] }).to include('WiFi', 'Air Conditioning')
    end

    it 'returns 404 if room does not exist' do
      get "/api/v1/hotels/#{hotel.id}/rooms/0"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /hotels/:hotel_id/rooms' do
    let(:valid_params) do
      {
        room: {
          name: 'Presidential Suite',
          description: 'Luxury suite with private pool',
          price: 500,
          location: 'Penthouse',
          capacity: 6,
          address: '123 Beach Ave',
          amenities_attributes: [{ name: 'Jacuzzi' }, { name: 'WiFi' }]
        }
      }
    end

    let(:invalid_params) do
      {
        room: {
          name: '', # invalid
          description: 'Broken room'
        }
      }
    end

    it 'creates a new room with amenities' do
      expect do
        post "/api/v1/hotels/#{hotel.id}/rooms", params: valid_params
      end.to change { hotel.rooms.count }.by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['room']['name']).to eq('Presidential Suite')
      expect(json['room']['amenities'].map { |a| a['name'] }).to include('Jacuzzi', 'WiFi')
    end

    it 'returns 422 with invalid params' do
      post "/api/v1/hotels/#{hotel.id}/rooms", params: invalid_params

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json).to have_key('errors')
    end
  end

  describe 'PATCH /hotels/:hotel_id/rooms/:id' do
    let(:valid_update) do
      {
        room: {
          price: 550,
          amenities_attributes: [{ name: 'Mini Bar' }]
        }
      }
    end

    let(:invalid_update) do
      {
        room: { name: '' } # invalid
      }
    end

    it 'updates the room and adds new amenities' do
      patch "/api/v1/hotels/#{hotel.id}/rooms/#{room.id}", params: valid_update
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['room']['price']).to eq(room.reload.price.to_f.to_s)
      expect(json['room']['amenities'].map { |a| a['name'] }).to include('Mini Bar')
    end

    it 'returns 422 with invalid params' do
      patch "/api/v1/hotels/#{hotel.id}/rooms/#{room.id}", params: invalid_update
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json).to have_key('errors')
    end
  end

  describe 'DELETE /hotels/:hotel_id/rooms/:id' do
    it 'deletes the room' do
      expect do
        delete "/api/v1/hotels/#{hotel.id}/rooms/#{room.id}"
      end.to change { hotel.rooms.count }.by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it 'returns 404 if room does not exist' do
      delete "/api/v1/hotels/#{hotel.id}/rooms/0"
      expect(response).to have_http_status(:not_found)
    end
  end
end
